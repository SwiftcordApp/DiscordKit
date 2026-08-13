//
//  Data+Base64.swift
//  DiscordKit
//
//  Created by Vincent on 13/8/26.
//

import Foundation

public extension Data {
    /// Decodes padded or unpadded Base64 using either the standard or URL-safe alphabet.
    init?(base64URL string: String) {
        var normalized = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingLength = (4 - normalized.count % 4) % 4
        normalized.append(String(repeating: "=", count: paddingLength))
        self.init(base64Encoded: normalized)
    }
}
