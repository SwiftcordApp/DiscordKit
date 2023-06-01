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

    /// An enum representing possible payloads
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

        // MARK: - Guilds

        /// Guild create event
        case guildCreate(Guild)
        /// Guild update event
        case guildUpdate(Guild)
        /// Guild delete event
        ///
        /// > This event may also be dispatched when a guild becomes unavailable due to a
        /// > server outage.
        case guildDelete(GuildUnavailable)

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

        // MARK: - Messages

        /// Message create event
        ///
        /// This event would be dispatched when a message is sent.
        ///
        /// - Parameter message: Created message
        case messageCreate(Message)
        /// Message update event
        ///
        /// This event would be dispatched when a message is edited, among other actions.
        ///
        /// - Parameter partialMessage: Partial message with the message `id` and updated fields
        case messageUpdate(PartialMessage)
        /// Message delete event
        ///
        /// - Parameter messageDelete: Information about the deleted message
        case messageDelete(MessageDelete)
        /// Bulk message delete event
        ///
        /// This can only be dispatched in response to bulk deletes by bots and the system,
        /// and cannot be initiated by users.
        ///
        /// - Parameter messageDeleteBulk: Information about the bulk-deleted messages
        case messageDeleteBulk(MessageDeleteBulk)
        /// Message read ACK event
        ///
        /// Sent to update message reading state. This is to acknowledge messages read
        /// from other clients.
        ///
        /// - Parameter messageACKEvt: Information about the acknowledged messages
        case messageACK(MessageACKEvt)

        // MARK: - Users

        /// User update event
        ///
        /// Dispatched for updates to the current user.
        case userUpdate(CurrentUser)

        /// Presence update event
        ///
        /// Dispatched when the presence of a user has changed, including for the current user.
        /// > (For user accounts only) By default, such updates are only dispatched for users in
        /// > open DMs, and require a ``SubscribeGuildEvts`` outgoing payload to enable
        /// > presence updates for users in a certain guild.
        case presenceUpdate(PresenceUpdate)

        // MARK: - Interactions

        /// Interaction create event
        ///
        ///
        case interaction(Interaction)

        // MARK: - Typing

        /// Typing start event
        ///
        /// Sent when a user starts typing in a channel that is subscribed to. Must subscribe
        /// to events from a specific channel before these events will be received.
        case typingStart(TypingStart)

        // MARK: - User account-specific events

        /// User settings proto update event
        ///
        /// Dispatched when the user settings proto changes.
        case settingsProtoUpdate(GatewaySettingsProtoUpdate)

        /// Handling this payload/event isn't implemented yet
        case unknown
    }

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
                // data = .userReady(try values.decode(ReadyEvt.self, forKey: .data))
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
*/
            // MARK: Guilds
            case .guildCreate: data = .guildCreate(try values.decode(Guild.self, forKey: .data))
            case .guildUpdate: data = .guildUpdate(try values.decode(Guild.self, forKey: .data))
            case .guildDelete: data = .guildDelete(try values.decode(GuildUnavailable.self, forKey: .data))
/*
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
*/
                // More events go here
            // MARK: Messages
            case .messageCreate: data = .messageCreate(try values.decode(Message.self, forKey: .data))
            case .messageUpdate: data = .messageUpdate(try values.decode(PartialMessage.self, forKey: .data))
            case .messageDelete: data = .messageDelete(try values.decode(MessageDelete.self, forKey: .data))
            case .messageDeleteBulk: data = .messageDeleteBulk(try values.decode(MessageDeleteBulk.self, forKey: .data))
            case .messageACK: data = .messageACK(try values.decode(MessageACKEvt.self, forKey: .data))

            // MARK: Users
            case .userUpdate: data = .userUpdate(try values.decode(CurrentUser.self, forKey: .data))
            case .presenceUpdate: data = .presenceUpdate(try values.decode(PresenceUpdate.self, forKey: .data))

            // MARK: Interactions
            case .interactionCreate: data = .interaction(try values.decode(Interaction.self, forKey: .data))

            // MARK: Typing
            case .typingStart: data = .typingStart(try values.decode(TypingStart.self, forKey: .data))
/*
            // MARK: - User account-specific events
            case .channelUnreadUpdate: data = try values.decode(ChannelUnreadUpdate.self, forKey: .data)
 */
            case .userSettingsProtoUpdate: data = .settingsProtoUpdate(
                try values.decode(GatewaySettingsProtoUpdate.self, forKey: .data)
            )
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
