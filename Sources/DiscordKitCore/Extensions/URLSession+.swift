//
//  File.swift
//  
//
//  Created by Vincent Kwok on 5/6/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(macOS, deprecated: 12.0, message: "Use the built-in API instead")
public extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
