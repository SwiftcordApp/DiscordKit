//
//  URL+.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 26/2/22.
//

import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
public extension URL {
	var mimeType: String {
		#if canImport(UniformTypeIdentifiers)
		UTType(filenameExtension: self.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        #else
        "application/octet-stream" // We'll just assume this for now, since UniformTypeIdentifiers isn't available on linux at the moment
        #endif
    }

    /// Appends one or more query items to the URL
    ///
    /// - Parameter items: Query item(s) to add
    func appendingQueryItems(_ items: URLQueryItem...) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { return self }

        var qItems = components.queryItems ?? []
        for item in items { qItems.append(item) }
        components.queryItems = qItems

        return components.url!
    }

    func setSize(size: Int?) -> URL {
        if let size = size {
            return self.appendingQueryItems(
                URLQueryItem(name: "size", value: String(size))
            )
        }
        return self
    }

    func setSize(width: Int?, height: Int?) -> URL {
        if let width = width, let height = height {
            return self.appendingQueryItems(
                URLQueryItem(name: "width", value: String(width)),
                URLQueryItem(name: "height", value: String(height))
            )
        }
        return self
    }
}
