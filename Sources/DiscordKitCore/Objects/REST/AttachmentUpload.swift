//
//  AttachmentUpload.swift
//  DiscordKit
//
//  Created by Vincent on 22/6/26.
//

import Foundation

public struct AttachmentUploadReservationFile: Encodable {
    public let filename: String
    public let file_size: Int
    public let id: String
    public let is_clip: Bool
    public let original_content_type: String?

    public init(
        filename: String,
        file_size: Int,
        id: String,
        is_clip: Bool = false,
        original_content_type: String? = nil
    ) {
        self.filename = filename
        self.file_size = file_size
        self.id = id
        self.is_clip = is_clip
        self.original_content_type = original_content_type
    }
}

public struct AttachmentUploadReservationRequest: Encodable {
    public let files: [AttachmentUploadReservationFile]

    public init(files: [AttachmentUploadReservationFile]) {
        self.files = files
    }
}

public struct AttachmentUploadReservationResponse: Decodable {
    public let attachments: [ReservedAttachmentUpload]

    public init(attachments: [ReservedAttachmentUpload]) {
        self.attachments = attachments
    }
}

public struct ReservedAttachmentUpload: Decodable {
    public let id: String
    public let upload_url: String
    public let upload_filename: String

    public init(id: String, upload_url: String, upload_filename: String) {
        self.id = id
        self.upload_url = upload_url
        self.upload_filename = upload_filename
    }

    enum CodingKeys: CodingKey {
        case id
        case upload_url
        case upload_filename
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // id can either be a number or string; try both but store as strings internally
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        } else {
            self.id = String(try container.decode(Int.self, forKey: .id))
        }

        upload_url = try container.decode(String.self, forKey: .upload_url)
        upload_filename = try container.decode(String.self, forKey: .upload_filename)
    }
}

public enum AttachmentUploadError: Error {
    case invalidUploadURL(String)
    case invalidUploadResponse
    case unexpectedResponseCode(Int)
}
