//
//  GatewayIO.swift
//  Contains structs to decode JSON sent back by Gateway. May not
//  include a complete list of data structs for all opcodes/events,
//  but that is being worked on gradually.
//
//  Created by Vincent Kwok on 7/6/22.
//

import Foundation

// MARK: - Main Gateway Sending/Receiving Structs

public struct GatewayIncoming: Decodable {
    public let opcode: GatewayIncomingOpcodes
    public var data: Data
    public let seq: Int? // Sequence #
    public let type: GatewayEvent?

    private enum CodingKeys: String, CodingKey {
        case opcode = "op"
        case data = "d"
        case seq = "s"
        case type = "t"
    }

    public enum Data {
        // MARK: - Gateway lifecycle
        /// Invalid session payload
        ///
        /// This signals that the current Gateway session has been invalidated
        /// and that the client should attempt to reconnect or resume depending on
        /// the `canResume` associated value.
        case invalidSession(canResume: Bool)
        /// Hello payload
        ///
        /// - Parameter hello: The hello payload, containing (most importantly) the `heartbeat_interval`
        case hello(GatewayHello)
        /// Ready event for users
        ///
        /// - Parameter ready: The ready event payload for users
        case userReady(ReadyEvt)
        /// Ready event for bots
        ///
        /// - Parameter ready: The ready event payload for bots
        case botReady(BotReadyEvt)
        /// Ready supplemental event
        ///
        /// - Parameter readySupp:
        case readySupplemental(ReadySuppEvt)
        /// Heartbeat payload
        ///
        /// Should be sent from the client every `heartbeat_interval`.
        /// > This payload may also be sent from the server. In that event,
        /// > the client should respond with a ``heartbeat`` payload
        /// > as soon as possible.
        case heartbeat
        /// Heartbeat acknowledge payload
        ///
        /// Sent from the server in response to a ``heartbeat`` payload.
        case heartbeatAck
        /// Reconnect payload
        ///
        /// Upon receiving this payload, the client should disconnect and attempt
        /// to reconnect, resuming if possible. This could be used for migration off
        /// old Gateway server instances.
        case reconnect
        /// Resumed event
        ///
        /// Informs the client that all missed events have been replayed after resuming.
        case resumed

        // MARK: - Channels
        /// Channel create event
        ///
        /// - Parameter channel: The channel that was created
        case channelCreate(Channel)
        /// Channel update event
        ///
        /// - Parameter channel: The channel that was updated
        case channelUpdate(Channel)
        /// Channel delete event
        ///
        /// - Parameter channel: The channel that was deleted
        case channelDelete(Channel)
        /// Thread create event
        ///
        /// - Parameter channel: The thread that was created
        case threadCreate(Channel)
        /// Thread update event
        ///
        /// - Parameter channel: The thread that was updated
        case threadUpdate(Channel)
        /// Thread delete event
        ///
        /// - Parameter channel: The thread that was deleted
        case threadDelete(Channel)

        /// Channel pin update
        ///
        /// Sent when a pin in a channel was updated (added, removed).
        ///
        /// - Parameter channelPinsUpdate: Some information about the updated pin
        case channelPinUpdate(ChannelPinsUpdate)
        
        /// Handling this payload/event isn't implemented yet
        case unknown
    }

    // Nothing I can do here too, really.
    // swiftlint:disable:next function_body_length
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let action = try values.decode(GatewayIncomingOpcodes.self, forKey: .opcode)

        opcode = action
        seq = try values.decodeIfPresent(Int.self, forKey: .seq)
        type = try values.decodeIfPresent(GatewayEvent.self, forKey: .type)

        switch action {
        // MARK: Gateway lifecycle
        case .hello: data = .hello(try values.decode(GatewayHello.self, forKey: .data))
        case .invalidSession: data = .invalidSession(canResume: try values.decode(Bool.self, forKey: .data))
        case .heartbeat: data = .heartbeat
        case .heartbeatAck: data = .heartbeatAck
        case .reconnect: data = .reconnect
        case .dispatchEvent:
            // Cue the long switch case to parse every single event
            switch type {
            case .ready:
                if let userReady = try? values.decode(ReadyEvt.self, forKey: .data) {
                    data = .userReady(userReady)
                } else {
                    data = .botReady(try values.decode(BotReadyEvt.self, forKey: .data))
                }
            case .readySupplemental: data = .readySupplemental(try values.decode(ReadySuppEvt.self, forKey: .data))
            case .resumed: data = .resumed

            // MARK: Channels
            case .channelCreate: data = .channelCreate(try values.decode(Channel.self, forKey: .data))
            case .channelUpdate: data = .channelUpdate(try values.decode(Channel.self, forKey: .data))
            case .channelDelete: data = .channelDelete(try values.decode(Channel.self, forKey: .data))
            case .threadCreate: data = .threadCreate(try values.decode(Channel.self, forKey: .data))
            case .threadUpdate: data = .threadUpdate(try values.decode(Channel.self, forKey: .data))
            case .threadDelete: data = .threadDelete(try values.decode(Channel.self, forKey: .data))

            case .channelPinUpdate: data = .channelPinUpdate(try values.decode(ChannelPinsUpdate.self, forKey: .data))
/*
            case .threadListSync: data = try values.decode(ThreadListSync.self, forKey: .data)
            case .threadMemberUpdate: data = try values.decode(ThreadMember.self, forKey: .data)
            case .threadMembersUpdate: data = try values.decode(ThreadMembersUpdate.self, forKey: .data)

            case .guildUpdate, .guildCreate: data = try values.decode(Guild.self, forKey: .data)
            case .guildDelete: data = try values.decode(GuildUnavailable.self, forKey: .data)
            case .guildBanAdd, .guildBanRemove: data = try values.decode(GuildBan.self, forKey: .data)
            case .guildEmojisUpdate: data = try values.decode(GuildEmojisUpdate.self, forKey: .data)
            case .guildStickersUpdate: data = try values.decode(GuildStickersUpdate.self, forKey: .data)
            case .guildIntegrationsUpdate: data = try values.decode(GuildIntegrationsUpdate.self, forKey: .data)
            case .guildMemberAdd: data = try values.decode(Member.self, forKey: .data)
            case .guildMemberRemove: data = try values.decode(GuildMemberRemove.self, forKey: .data)
            case .guildMemberUpdate: data = try values.decode(GuildMemberUpdate.self, forKey: .data)
            case .guildRoleCreate: data = try values.decode(GuildRoleEvt.self, forKey: .data)
            case .guildRoleUpdate: data = try values.decode(GuildRoleEvt.self, forKey: .data)
            case .guildRoleDelete: data = try values.decode(GuildRoleDelete.self, forKey: .data)
            case .guildSchEvtCreate, .guildSchEvtUpdate, .guildSchEvtDelete: data = try values.decode(GuildScheduledEvent.self, forKey: .data)
            case .guildSchEvtUserAdd, .guildSchEvtUserRemove: data = try values.decode(GuildSchEvtUserEvt.self, forKey: .data)

                // More events go here
            case .messageCreate: data = try values.decode(Message.self, forKey: .data)
            case .messageUpdate: data = try values.decode(PartialMessage.self, forKey: .data)
            case .messageDelete: data = try values.decode(MessageDelete.self, forKey: .data)
            case .messageACK: data = try values.decode(MessageACKEvt.self, forKey: .data)
            case .messageDeleteBulk: data = try values.decode(MessageDeleteBulk.self, forKey: .data)
            case .presenceUpdate: data = try values.decode(PresenceUpdate.self, forKey: .data)
                // Add the remaining like 100 events

            case .userUpdate: data = try values.decode(CurrentUser.self, forKey: .data)
            case .typingStart: data = try values.decode(TypingStart.self, forKey: .data)

                // User-specific events
            case .channelUnreadUpdate: data = try values.decode(ChannelUnreadUpdate.self, forKey: .data)
            case .userSettingsUpdate: data = try values.decode(UserSettings.self, forKey: .data)
            case .userSettingsProtoUpdate: data = try values.decode(GatewaySettingsProtoUpdate.self, forKey: .data)*/
            default: data = .unknown
            }
        }
    }
}

public struct GatewayOutgoing<T: OutgoingGatewayData>: Encodable {
    enum CodingKeys: String, CodingKey {
        case opcode = "op"
        case data = "d"
        case seq = "s"
    }

    public let opcode: GatewayOutgoingOpcodes
    public let data: T?
    public let seq: Int? // Sequence #
}
