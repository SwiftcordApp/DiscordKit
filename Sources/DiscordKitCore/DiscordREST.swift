//
//  DiscordREST.swift
//  
//
//  Created by Vincent Kwok on 5/6/22.
//

import Foundation
import Logging

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class DiscordREST {
    static let log = Logger(label: "DiscordREST", level: nil)
    // How empty, everything is broken into smaller files (for now xD)

    static let session: URLSession = {
        // Create URL Session Configuration
        let configuration = URLSessionConfiguration.default

        // Define Request Cache Policy (causes stale data sometimes)
        // configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }()

    internal var token: String?

    public init() {}

    public func setToken(token: String?) {
        self.token = token
    }
}
