//
//  GatewayIO.swift
//  
//
//  Created by Vincent Kwok on 7/6/22.
//

import Foundation

// MARK: - Main Gateway Sending/Receiving Structs

public struct GatewayIncoming: Decodable {
    public let op: GatewayIncomingOpcodes
    public var d: GatewayData?
    public let s: Int? // Sequence #
    public let t: GatewayEvent?
    public var primitiveData: Any?

    private enum CodingKeys: String, CodingKey {
        case op
        case d
        case s
        case t
   }

    // swiftlint:disable cyclomatic_complexity
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let action = try values.decode(GatewayIncomingOpcodes.self, forKey: .op)

        op = action
        s = try values.decodeIfPresent(Int.self, forKey: .s)
        t = try values.decodeIfPresent(GatewayEvent.self, forKey: .t)

        switch action {
        case .hello: d = try values.decode(GatewayHello.self, forKey: .d)
        case .invalidSession: primitiveData = try values.decode(Bool.self, forKey: .d) // Parse data as bool
        case .dispatchEvent:
            // Cue the long switch case to parse every single event
            switch t {
            case .ready: d = try values.decode(ReadyEvt.self, forKey: .d)
            case .readySupplemental: d = try values.decode(ReadySuppEvt.self, forKey: .d)
            case .resumed: d = nil
            case .channelCreate, .channelUpdate, .channelDelete, .threadCreate, .threadUpdate, .threadDelete:
                d = try values.decode(Channel.self, forKey: .d)
            case .channelPinUpdate: d = try values.decode(ChannelPinsUpdate.self, forKey: .d)

            case .threadListSync: d = try values.decode(ThreadListSync.self, forKey: .d)
            case .threadMemberUpdate: d = try values.decode(ThreadMember.self, forKey: .d)
            case .threadMembersUpdate: d = try values.decode(ThreadMembersUpdate.self, forKey: .d)

            case .guildUpdate, .guildCreate: d = try values.decode(Guild.self, forKey: .d)
            case .guildDelete: d = try values.decode(GuildUnavailable.self, forKey: .d)
            case .guildBanAdd, .guildBanRemove: d = try values.decode(GuildBan.self, forKey: .d)
            case .guildEmojisUpdate: d = try values.decode(GuildEmojisUpdate.self, forKey: .d)
            case .guildStickersUpdate: d = try values.decode(GuildStickersUpdate.self, forKey: .d)
            case .guildIntegrationsUpdate: d = try values.decode(GuildIntegrationsUpdate.self, forKey: .d)
            case .guildMemberAdd: d = try values.decode(Member.self, forKey: .d)
            case .guildMemberRemove: d = try values.decode(GuildMemberRemove.self, forKey: .d)
            case .guildMemberUpdate: d = try values.decode(GuildMemberUpdate.self, forKey: .d)
            case .guildRoleCreate: d = try values.decode(GuildRoleEvt.self, forKey: .d)
            case .guildRoleUpdate: d = try values.decode(GuildRoleEvt.self, forKey: .d)
            case .guildRoleDelete: d = try values.decode(GuildRoleDelete.self, forKey: .d)
            case .guildSchEvtCreate, .guildSchEvtUpdate, .guildSchEvtDelete: d = try values.decode(GuildScheduledEvent.self, forKey: .d)
            case .guildSchEvtUserAdd, .guildSchEvtUserRemove: d = try values.decode(GuildSchEvtUserEvt.self, forKey: .d)

                // More events go here
            case .messageCreate: d = try values.decode(Message.self, forKey: .d)
            case .messageUpdate: d = try values.decode(PartialMessage.self, forKey: .d)
            case .messageDelete: d = try values.decode(MessageDelete.self, forKey: .d)
            case .messageACK: d = try values.decode(MessageACKEvt.self, forKey: .d)
            case .messageDeleteBulk: d = try values.decode(MessageDeleteBulk.self, forKey: .d)
            case .presenceUpdate: d = try values.decode(PresenceUpdate.self, forKey: .d)
                // Add the remaining like 100 events

            case .userUpdate: d = try values.decode(CurrentUser.self, forKey: .d)
            case .typingStart: d = try values.decode(TypingStart.self, forKey: .d)

                // User-specific events
            case .channelUnreadUpdate: d = try values.decode(ChannelUnreadUpdate.self, forKey: .d)
            case .userSettingsUpdate: d = try values.decode(UserSettings.self, forKey: .d)
            case .userSettingsProtoUpdate: d = try values.decode(GatewaySettingsProtoUpdate.self, forKey: .d)
            default: d = nil
            }
        default:
            d = nil
        }
    }
}

public struct GatewayOutgoing<T: OutgoingGatewayData>: Encodable {
    public let op: GatewayOutgoingOpcodes
    public let d: T?
    public let s: Int? // Sequence #
}
