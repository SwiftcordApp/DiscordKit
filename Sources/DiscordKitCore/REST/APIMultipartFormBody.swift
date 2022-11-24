//
//  APIMultipartFormBody.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 14/5/22.
//

import Foundation

public extension DiscordREST {
    static func createMultipartBody(
        with payloadJson: Data?,
        boundary: String,
        attachments: [URL]
    ) -> Data {
        var body = Data()

        for (num, attachment) in attachments.enumerated() {
            guard let name = try? attachment.resourceValues(forKeys: [URLResourceKey.nameKey]).name else {
                continue
            }
            guard let attachmentData = try? Data(contentsOf: attachment) else {
                DiscordREST.log.error("Could not get data of attachment #\(num)")
                continue
            }

			body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"files[\(num)]\"; filename=\"\(name)\"\r\n".data(using: .utf8)!
            )
            body.append("Content-Type: \(attachment.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(attachmentData)
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
