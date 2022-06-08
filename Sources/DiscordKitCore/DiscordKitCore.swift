//
//  File.swift
//  
//
//  Created by Vincent Kwok on 5/6/22.
//

import Foundation
import Logging
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import OpenCombineShim

public class DiscordREST: ObservableObject {
    static let subsystem = "com.cryptoalgo.discordapi"

    static let log = Logger(label: DiscordREST.subsystem) //Logger(subsystem: Bundle.main.bundleIdentifier ?? DiscordREST.subsystem, category: "DiscordREST")
    // How empty, everything is broken into smaller files (for now xD)

    static var session: URLSession = {
        // Create URL Session Configuration
        let configuration = URLSessionConfiguration.default

        // Define Request Cache Policy (causes stale data sometimes)
        // configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }()

    internal var token: String?

    public init(token: String? = nil) {
        self.token = token
    }

    public func setToken(token: String) {
        self.token = token
    }
}
