//
//  GatewayIO.swift
//  
//
//  Created by Vincent Kwok on 7/6/22.
//

import Foundation

// MARK: - Main Gateway Sending/Receiving Structs

public struct GatewayIncoming: Decodable {
    public let opcode: GatewayIncomingOpcodes
    public var data: GatewayData?
    public let seq: Int? // Sequence #
    public let type: GatewayEvent?
    public var primitiveData: Any?

    private enum CodingKeys: String, CodingKey {
        case opcode = "op"
        case data = "d"
        case seq = "s"
        case type = "t"
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
        case .hello: data = try values.decode(GatewayHello.self, forKey: .data)
        case .invalidSession: primitiveData = try values.decode(Bool.self, forKey: .data) // Parse data as bool
        case .dispatchEvent:
            // Cue the long switch case to parse every single event
            switch type {
            case .ready: data = try values.decode(ReadyEvt.self, forKey: .data)
            case .readySupplemental: data = try values.decode(ReadySuppEvt.self, forKey: .data)
            case .resumed: data = nil
            case .channelCreate, .channelUpdate, .channelDelete, .threadCreate, .threadUpdate, .threadDelete:
                data = try values.decode(Channel.self, forKey: .data)
            case .channelPinUpdate: data = try values.decode(ChannelPinsUpdate.self, forKey: .data)

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
            case .userSettingsProtoUpdate: data = try values.decode(GatewaySettingsProtoUpdate.self, forKey: .data)
            default: data = nil
            }
        default:
            data = nil
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
