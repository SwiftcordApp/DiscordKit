//
//  APIAttachmentUpload.swift
//  DiscordKit
//
//  Created by Vincent on 22/6/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension DiscordREST {
    func reserveChannelAttachments(
        channelID: Snowflake,
        files: [AttachmentUploadReservationFile]
    ) async throws -> AttachmentUploadReservationResponse {
        try await postReq(
            path: "channels/\(channelID)/attachments",
            body: AttachmentUploadReservationRequest(files: files)
        )
    }

    func deleteAttachment(uploadedFilename: String) async throws {
        try await deleteReq(path: "attachments/\(uploadedFilename)")
    }

    func uploadAttachmentFile(
        to uploadURL: URL,
        from fileURL: URL,
        progress: @escaping (Double) -> Void = { _ in }
    ) async throws {
        let upload = AttachmentUploadRequest(
            uploadURL: uploadURL,
            fileURL: fileURL,
            progress: progress
        )
        try await upload.start()
    }
}

private final class AttachmentUploadRequest {
    private let uploadURL: URL
    private let fileURL: URL
    private let progress: (Double) -> Void

    private var task: URLSessionUploadTask?
    private var session: URLSession?

    init(uploadURL: URL, fileURL: URL, progress: @escaping (Double) -> Void) {
        self.uploadURL = uploadURL
        self.fileURL = fileURL
        self.progress = progress
    }

    func start() async throws {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                var request = URLRequest(url: uploadURL)
                request.httpMethod = "PUT"
                request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

                let delegate = SessionDelegate(progress: progress)
                let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
                self.session = session

                let task = session.uploadTask(with: request, fromFile: fileURL) { _, response, error in
                    session.finishTasksAndInvalidate()

                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.resume(throwing: AttachmentUploadError.invalidUploadResponse)
                        return
                    }

                    guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                        continuation.resume(
                            throwing: AttachmentUploadError.unexpectedResponseCode(httpResponse.statusCode)
                        )
                        return
                    }

                    self.progress(1)
                    continuation.resume(returning: ())
                }

                self.task = task
                progress(0)
                task.resume()
            }
        } onCancel: {
            task?.cancel()
            session?.invalidateAndCancel()
        }
    }

    private final class SessionDelegate: NSObject, URLSessionTaskDelegate {
        private let progress: (Double) -> Void

        init(progress: @escaping (Double) -> Void) {
            self.progress = progress
        }

        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didSendBodyData bytesSent: Int64,
            totalBytesSent: Int64,
            totalBytesExpectedToSend: Int64
        ) {
            guard totalBytesExpectedToSend > 0 else { return }
            progress(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
        }
    }
}
