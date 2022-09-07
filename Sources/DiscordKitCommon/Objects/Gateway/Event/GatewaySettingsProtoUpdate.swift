//
//  GatewaySettingsProtoUpdate.swift
//  
//
//  Created by Vincent Kwok on 7/9/22.
//

import Foundation

public struct GatewaySettingsProtoUpdate: GatewayData {
    public let settings: GatewaySettingsProto
    public let partial: Bool
}

public struct GatewaySettingsProto: GatewayData {
    public let type: Int
    public let proto: String
}
