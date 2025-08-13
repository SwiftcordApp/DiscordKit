//
//  APIMultipartFormBody.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 14/5/22.
//

import Foundation

#if canImport(AppIntents)
import AppIntents

@available(macOS 13.0, iOS 16.0, *)
extension IntentFile: Attachable {
    public func asAttachable() throws -> AttachableData {
        AttachableData(data: self.data, name: self.filename, mimeType: self.type?.preferredMIMEType ?? "application/octet-stream")
    }
}
#endif

public protocol Attachable {
    func asAttachable() throws -> AttachableData
}

public struct AttachableData {
    public let data: Data
    public let name: String
    public let mimeType: String

	public init(data: Data, name: String, mimeType: String) {
        self.data = data
        self.name = name
        self.mimeType = mimeType
    }
}

extension URL: Attachable {
    public func asAttachable() throws -> AttachableData {
        let name = try self.resourceValues(forKeys: [URLResourceKey.nameKey]).name ?? UUID().uuidString
        return AttachableData(data: try Data(contentsOf: self), name: name, mimeType: self.mimeType)
    }
}

public extension DiscordREST {
    static func createMultipartBody(
        with payloadJson: Data?,
        boundary: String,
        attachments: [some Attachable]
    ) -> Data {
        var body = Data()

        for (num, attachment) in attachments.enumerated() {
            guard let attachmentData = try? attachment.asAttachable() else {
                DiscordREST.log.error("Could not get data of attachment #\(num)")
                continue
            }
            let name = attachmentData.name

			body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"files[\(num)]\"; filename=\"\(name)\"\r\n".data(using: .utf8)!
            )
            body.append("Content-Type: \(attachmentData.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(attachmentData.data)
            body.append("\r\n".data(using: .utf8)!)
        }

        if let payloadJson = payloadJson {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(payloadJson)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
