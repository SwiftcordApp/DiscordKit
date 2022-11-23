//
//  Intents.swift
//  
//
//  Created by Vincent Kwok on 21/11/22.
//

import Foundation

/// List of intents to select the events that should be sent back from the gateway
///
///
public struct Intents: OptionSet, Encodable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    /// Guilds
    static public let guilds       = Self(rawValue: 1 << 0)
    /// Guild members
    ///
    /// > Warning: This is a privileged intent
    static public let guildMembers = Self(rawValue: 1 << 1)
    /// Guild bans
    static public let guildBans    = Self(rawValue: 1 << 2)
    /// Guild emote and stickers
    static public let emoteSticker = Self(rawValue: 1 << 3)
    /// Guild integrations
    static public let integrations = Self(rawValue: 1 << 4)
    /// Guild webhooks
    static public let webhooks     = Self(rawValue: 1 << 5)
    /// Guild invites
    static public let guildInvites = Self(rawValue: 1 << 6)
    /// Guild voice states
    static public let voiceStates  = Self(rawValue: 1 << 7)
    /// Guild presences
    ///
    /// > Warning: This is a privileged intent
    static public let presences    = Self(rawValue: 1 << 8)
    /// Guild messages
    static public let messages     = Self(rawValue: 1 << 9)
    /// Guild message reactions
    static public let reactions    = Self(rawValue: 1 << 10)
    /// Guild message typing
    static public let msgTyping    = Self(rawValue: 1 << 11)
    /// Direct messages
    static public let directMsgs   = Self(rawValue: 1 << 12)
    /// DM reactions
    static public let dmReactions  = Self(rawValue: 1 << 13)
    /// DM message typing
    static public let dmMsgTyping  = Self(rawValue: 1 << 14)
    /// Message content
    ///
    /// This intent does not represent individual events, but rather affects what data
    /// is present for events that could contain message content fields.
    /// > Warning: This is a privileged intent
    static public let messageContent = Self(rawValue: 1 << 15)
    /// Guild scheduled events
    static public let scheduledEvt = Self(rawValue: 1 << 16)
    /// Auto moderation configuration
    static public let autoModCfg   = Self(rawValue: 1 << 20)
    /// Auto moderation execution
    static public let autoModExec  = Self(rawValue: 1 << 20)

    static public let unprivileged: Self = [.guilds, .guildBans, .emoteSticker, .integrations, .webhooks, .guildInvites, .voiceStates, .messages, .reactions, .msgTyping, .directMsgs, .dmReactions, .dmMsgTyping, .scheduledEvt, .autoModCfg, .autoModExec]
    static public let privileged: Self = [.guildMembers, .presences, .messageContent]
    static public let all: Self = [.unprivileged, .privileged]
}
