//
//  Client.swift
//  
//
//  Created by Vincent Kwok on 21/11/22.
//

import Foundation
import Logging
import DiscordKitCore

/// The main client class for bots to interact with Discord's API. Only one client is allowed to be logged in at a time.
public final class Client {
    // REST handler
    public let rest = DiscordREST()

    // MARK: Gateway vars
    fileprivate var gateway: RobustWebSocket?
    private var evtHandlerID: EventDispatch.HandlerIdentifier?

    // MARK: Application Command Handlers
    fileprivate var appCommandHandlers: [Snowflake: NewAppCommand.Handler] = [:]

    // MARK: Event publishers
    private let notificationCenter = NotificationCenter()
    /// An event that is fired when the bot is connected to discord and ready to do bot-like things
    public let ready: NCWrapper<()>
    /// An event that is fired whenever a message is created in any channel the bot has access to.
    public let messageCreate: NCWrapper<Message>
    /// An event that is fired when a new user joins a guild that the bot is in.
    public let guildMemberAdd: NCWrapper<Member>

    // MARK: Configuration Members
    /// The intents configured for this client.
    /// 
    /// ## See also 
    /// - [Intents on the Discord Developer documentation](https://discord.com/developers/docs/topics/gateway#gateway-intents)
    public let intents: Intents
    /// Set this to false to disable blocking the main thread when calling ``login(token:)``.
    /// 
    /// This is an advanced use case, and considered unsafe to disable, however we provide the option to do so if you wish.
    /// It is strongly recommended to instead use a listener on ``ready`` to perform operations after your bot is logged in.
    /// 
    /// ## See also
    /// - ``ready``
    public var blockOnLogin: Bool = true

    // Logger
    private static let logger = Logger(label: "Client", level: nil)

    // MARK: Information about the bot
    /// The user object of the bot
    public fileprivate(set) var user: User?
    /// The application ID of the bot
    ///
    /// This is used for registering application commands, among other actions.
    public fileprivate(set) var applicationID: String?
    /// A list of Guild IDs of the guilds that the bot is in.
    /// 
    /// To get the full ``Guild`` object, call ``getGuild(id:)``.
    public fileprivate(set) var guilds: [Snowflake]?

    /// Static reference to the currently logged in client.
    public fileprivate(set) static var current: Client?

    /// Create a new Client, with the intents provided.
    /// - Parameter intents: The intents the bot should have. If no value is passed, `Intents.unprivileged`. Use array notation to pass multiple.
    public init(intents: Intents = .unprivileged) {
        self.intents = intents
        // Override default config for bots
        DiscordKitConfig.default = .init(
            properties: .init(browser: DiscordKitConfig.libraryName, device: DiscordKitConfig.libraryName),
            intents: intents
        )

        // Init event wrappers
        ready = .init(.ready, notificationCenter: notificationCenter)
        messageCreate = .init(.messageCreate, notificationCenter: notificationCenter)
        guildMemberAdd = .init(.guildMemberAdd, notificationCenter: notificationCenter)
    }

    deinit {
        disconnect()
    }

    /// Login to the Discord API with a manually provided token
    ///
    /// Calling this function will cause a connection to the Gateway to be attempted, using the provided token.
    ///
    /// > Important: This method will block the main thread for the rest of the execution time.
    /// > This means that any code after this call in the main thread will never run, and should be considered unreachable.
    /// > If you want to perform operations immediately after your bot is logged in, add a listener to ``ready``.
    /// 
    /// > Warning: Calling this method while a bot is already logged in will disconnect that bot and 
    /// > replace it with the new one. You cannot have 2 bots logged in at the same time.
    /// 
    /// ## See Also
    /// - ``login(filePath:)``
    /// - ``login()``
    public func login(token: String) {
        if Client.current != nil {
            Client.current?.disconnect()
        }
        rest.setToken(token: token)
        gateway = .init(token: token)
        evtHandlerID = gateway?.onEvent.addHandler { [weak self] data in
            self?.handleEvent(data)
        }
        Client.current = self

        // Handle exit with SIGINT
        let signalCallback: sig_t = { signal in
            print("Gracefully stopping...")
            Client.current?.disconnect()
            sleep(1) // give other threads a tiny amount of time to finish up
            exit(signal)
        }
        signal(SIGINT, signalCallback)

        if blockOnLogin {
            // Block thread to prevent exit
            RunLoop.main.run()
        }

    }

    /// Login to the Discord API with a token stored in a file
    ///
    /// This method attempts to retrieve the token from the file provided,
    /// and calls ``login(token:)`` if it was found. Any API calls made before this method is ran will fail.
    ///
    /// > Important: This method will block the main thread for the rest of the execution time.
    /// > This means that any code after this call in the main thread will never run, and should be considered unreachable.
    /// > If you want to perform operations immediately after your bot is logged in, add a listener to ``ready``.
    /// 
    /// > Warning: Calling this method while a bot is already logged in will disconnect that bot and 
    /// > replace it with the new one. You cannot have 2 bots logged in at the same time.
    ///
    /// - Parameter filePath: A path to the file that contains your Discord bot's token
    ///
    /// - Throws: `AuthError.emptyToken` if the file is empty.
    ///
    /// ## See Also
    /// - ``login()``
    /// - ``login(token:)``
    public func login(filePath: String) throws {
        let token = try String(contentsOfFile: filePath).trimmingCharacters(in: .whitespacesAndNewlines)
        if token.isEmpty {
            throw AuthError.emptyToken
        }
        login(token: token)
    }

    /// Login to the Discord API with a token from the environment
    ///
    /// This method attempts to retrieve the token from the `DISCORD_TOKEN` environment
    /// variable, and calls ``login(token:)`` if it was found. Any API calls made before this method is ran will fail.
    /// 
    /// > Important: This method will block the main thread for the rest of the execution time.
    /// > This means that any code after this call in the main thread will never run, and should be considered unreachable.
    /// > If you want to perform operations immediately after your bot is logged in, add a listener to ``ready``.
    /// 
    /// > Warning: Calling this method while a bot is already logged in will disconnect that bot's session and 
    /// > replace it with the new one. You cannot have 2 bots logged in at the same time.
    /// 
    /// - Throws: `AuthError.emptyToken` if the `DISCORD_TOKEN` environment variable is empty. 
    /// `AuthError.missingEnvVar` if the `DISCORD_TOKEN` environment variable does not exist.
    ///
    /// ## See Also
    /// - ``login(filePath:)``
    /// - ``login(token:)``
    public func login() throws {
        let token = ProcessInfo.processInfo.environment["DISCORD_TOKEN"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let token = token {
            if token.isEmpty {
                throw AuthError.emptyToken
            }
            login(token: token)
        } else {
            throw AuthError.missingEnvVar
        }
    }

    /// Disconnect from the gateway, undoes ``login(token:)``
    ///
    /// Request that the gateway connection be gracefully closed. Also destroys
    /// the REST hander. Following this call, none of the APIs would function. Subsequently,
    /// connection can be restored by calling ``login(token:)`` again.
    public func disconnect() {
        // Remove event listeners and gracefully disconnect from Gateway
        gateway?.close(code: .normalClosure)
        if let evtHandlerID = evtHandlerID { _ = gateway?.onEvent.removeHandler(handler: evtHandlerID) }
        // Clear member vars
        gateway = nil
        rest.setToken(token: nil)
        applicationID = nil
        user = nil
        Client.current = nil
    }
}

enum AuthError: Error {
    case invalidToken
    case missingFile
    case missingEnvVar
    case emptyToken
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return NSLocalizedString("A user-friendly description of the error.", comment: "My error")
        case .missingFile:
            return NSLocalizedString("The file does not exist, or your bot does not have read access to it.", comment: "File access error.")
        case .missingEnvVar:
            return NSLocalizedString("The \"DISCORD_TOKEN\" environment variable was not found.", comment: "ENV VAR access error.")
        case .emptyToken:
            return NSLocalizedString("The token provided is empty.", comment: "Invalid token.")
        }
    }
}

// Gateway API
extension Client {
    /// `true` if the bot is connected to discord and ready to do bot-like things.
    public var isReady: Bool { gateway?.sessionOpen == true }

    /// Invoke the handler associated with the respective commands
    private func invokeCommandHandler(_ commandData: Interaction.Data.AppCommandData, id: Snowflake, token: String) {
        if let handler = appCommandHandlers[commandData.id] {
            Self.logger.trace("Invoking application handler", metadata: ["command.name": "\(commandData.name)"])
            Task {
                await handler(.init(
                    optionValues: commandData.options ?? [],
                    rest: rest, applicationID: applicationID!, interactionID: id, token: token
                ))
            }
        }
    }

    /// Handle a subset of gateway events
    private func handleEvent(_ data: GatewayIncoming.Data) {
        switch data {
        case .botReady(let readyEvt):
            let firstTime = applicationID == nil
            // Set several members with info about the bot
            applicationID = readyEvt.application.id
            user = readyEvt.user
            guilds = readyEvt.guilds.map({ $0.id })
            if firstTime {
                Self.logger.info("Bot client ready", metadata: [
                    "user.id": "\(readyEvt.user.id)",
                    "application.id": "\(readyEvt.application.id)"
                ])
                ready.emit()
            }
        case .messageCreate(let message):
            Task {
                let botMessage = await Message(from: message, rest: rest)
                messageCreate.emit(value: botMessage)
            }
        case .interaction(let interaction):
            Self.logger.trace("Received interaction", metadata: ["interaction.id": "\(interaction.id)"])
            // Handle interactions based on type
            switch interaction.data {
            case .applicationCommand(let commandData):
                invokeCommandHandler(commandData, id: interaction.id, token: interaction.token)
            case .messageComponent(let componentData):
                print("Component interaction: \(componentData.custom_id)")
            default: break
            }
        case .guildMemberAdd(let member):
            let botMember = Member(from: member, rest: rest)
            guildMemberAdd.emit(value: botMember)
        default:
            break
        }
    }
}

// MARK: - REST-related API
public extension Client {
    // MARK: Interactions
    /// Register Application Commands with a result builder
    func registerApplicationCommands(
        guild: Snowflake? = nil, @AppCommandBuilder _ commands: () -> [NewAppCommand]
    ) async throws {
        try await registerApplicationCommands(guild: guild, commands())
    }
    /// Register Application Commands with the provided application command create structs
    func registerApplicationCommands(guild: Snowflake? = nil, _ commands: [NewAppCommand]) async throws {
        let registeredCommands = try await rest.bulkOverwriteCommands(commands, applicationID: applicationID!, guildID: guild)
        for command in commands {
            // Find the actual registered command
            // By comparing both the type and name, we ensure there is no ambiguity.
            guard let registeredCommand = registeredCommands.first(where: {
                $0.type == command.type && $0.name == command.name
            }) else {
                Self.logger.warning("Could not find registered command corresponding to new command", metadata: [
                    "command.name": "\(command.name)",
                    "command.type": "\(command.type)"
                ])
                continue
            }
            appCommandHandlers[registeredCommand.id] = command.handler
        }
    }
    /// Gets a ``Guild`` object from a guild ID.
    /// 
    /// - Parameter id: The Snowflake ID of a Guild that your bot is in.
    /// - Returns: A ``Guild`` object containing information about the guild.
    func getGuild(id: Snowflake) async throws -> Guild {
        return try await Guild(rest.getGuild(id: id))
    }

    func getGuildRoles(id: Snowflake) async throws -> [Role] {
        return try await rest.getGuildRoles(id: id)
    }
}
