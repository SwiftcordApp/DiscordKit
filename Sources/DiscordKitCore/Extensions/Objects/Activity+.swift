//
//  Activity+.swift
//  DiscordKit
//
//  Created by Vincent on 9/8/26.
//

import Foundation

public struct ActivityAssetResource: Equatable, Sendable {
    public let url: URL
    public let isAnimated: Bool

    public init(url: URL, isAnimated: Bool) {
        self.url = url
        self.isAnimated = isAnimated
    }
}

public extension Activity {
    /// Resolves the asset-key forms emitted in Gateway rich-presence payloads.
    func assetResource(for key: String, size: Int) -> ActivityAssetResource? {
        guard size > 0 else { return nil }

        if let value = key.droppingPrefix("spotify:") {
            return resource(base: "https://i.scdn.co/image/", path: value)
        }
        if let value = key.droppingPrefix("twitch:") {
            return resource(
                base: "https://static-cdn.jtvnw.net/previews-ttv/",
                path: "live_user_\(value)-\(size)x\(size).jpg"
            )
        }
        if let value = key.droppingPrefix("youtube:") {
            return resource(base: "https://i.ytimg.com/", pathComponents: ["vi", value, "hqdefault_live.jpg"])
        }
        if let path = key.droppingPrefix("mp:") {
            guard var url = url(base: "https://media.discordapp.net/", pathComponents: path.split(separator: "/").map(String.init)) else {
                return nil
            }
            let extensionName = url.pathExtension.lowercased()
            let isAnimated = ["gif", "webp", "avif"].contains(extensionName)
            var queryItems = [
                URLQueryItem(name: "width", value: String(size)),
                URLQueryItem(name: "height", value: String(size))
            ]
            if extensionName == "gif" {
                queryItems.append(URLQueryItem(name: "format", value: "webp"))
            }
            if isAnimated {
                queryItems.append(URLQueryItem(name: "animated", value: "true"))
            }
            url = url.appendingQueryItems(queryItems)
            return ActivityAssetResource(url: url, isAnimated: isAnimated)
        }

        guard let application_id else { return nil }
        guard var url = url(
            base: DiscordKitConfig.default.cdnURL,
            pathComponents: ["app-assets", application_id, key]
        ) else { return nil }
        url.appendPathExtension("png")
        return ActivityAssetResource(url: url.setSize(size: size), isAnimated: false)
    }

    private func resource(base: String, path: String) -> ActivityAssetResource? {
        resource(base: base, pathComponents: [path])
    }

    private func resource(base: String, pathComponents: [String]) -> ActivityAssetResource? {
        guard let url = url(base: base, pathComponents: pathComponents) else { return nil }
        return ActivityAssetResource(url: url, isAnimated: false)
    }

    private func url(base: String, pathComponents: [String]) -> URL? {
        guard var url = URL(string: base) else { return nil }
        for component in pathComponents where !component.isEmpty {
            url.appendPathComponent(component)
        }
        return url
    }
}

private extension String {
    func droppingPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        let value = String(dropFirst(prefix.count))
        return value.isEmpty ? nil : value
    }
}

private extension URL {
    func appendingQueryItems(_ items: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        components.queryItems = (components.queryItems ?? []) + items
        return components.url ?? self
    }
}
