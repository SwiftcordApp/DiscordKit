//
//  Gateway.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

/*
 but enough for what this app needs to do.
 */

public enum GatewayCloseCode: Int {
    case unknown = 4000
    case unknownOpcode = 4001
    case decodeErr = 4002
    case notAuthenthicated = 4003
    case authenthicationFail = 4004
    case alreadyAuthenthicated = 4005
    case invalidSeq = 4007
    case rateLimited = 4008
    case timedOut = 4009
    case invalidVersion = 4012
    case invalidIntent = 4013
    case disallowedIntent = 4014
}

// MARK: - Gateway Opcode enums
public enum GatewayOutgoingOpcodes: Int, Codable {
    case heartbeat = 1
    case identify = 2
    case presenceUpdate = 3
    case voiceStateUpdate = 4
    case resume = 6 // Attempt to resume disconnected session
    case requestGuildMembers = 8
    case subscribeGuildEvents = 14
}

public enum GatewayIncomingOpcodes: Int, Codable {
    case dispatchEvent = 0 // Event dispatched
    case heartbeat = 1
    case reconnect = 7 // Server is closing connection, should disconnect and resume
    case invalidSession = 9
    case hello = 10
    case heartbeatAck = 11
}
