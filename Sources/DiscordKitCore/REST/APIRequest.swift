//
//  APIRequest.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Utility wrappers for easy request-making
public extension DiscordREST {
    enum RequestError: Error {
        case unexpectedResponseCode(_ code: Int)
        case invalidResponse
        case superEncodeFailure
        case jsonDecodingError(error: Error) // This is not strongly typed because it was simpler to just use one catch
        case genericError(reason: String)
    }

    /// The few supported request methods
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    /// Make a Discord REST API request
    ///
    /// Low level method for Discord API requests, meant to be as generic
    /// as possible. You should call other wrapper methods like `getReq()`,
    /// `postReq()`, `deleteReq()`, etc. where possible instead.
    ///
    /// - Parameters:
    ///   - path: API endpoint path relative to `GatewayConfig.restBase`
    ///   - query: Array of URL query items
    ///   - attachments: URL of file attachments, for messages with attachments.
    ///   Sends a request of type `multipart/form-data` if there are attachments,
    ///   otherwise a `application/json` request.
    ///   - body: Request body, should be a JSON string
    ///   - method: Method for the request
    ///   (currently `.get`, `.post`, `.delete` or `.patch`)
    ///
    /// - Returns: Raw `Data` of response, or nil if the request failed
    func makeRequest(
        path: String,
        query: [URLQueryItem] = [],
        attachments: [URL] = [],
        body: Data? = nil,
        method: RequestMethod = .get
    ) async throws -> Data {
        assert(token != nil, "Token should not be nil. Please set a token before using the REST API.")
        let token = token! // Force unwrapping is appropriete here

        Self.log.trace("Making request", metadata: [
            "method": "\(method)",
            "path": "\(path)"
        ])

        let apiURL = DiscordKitConfig.default.restBase.appendingPathComponent(path, isDirectory: false)

        // Add query params (if any)
        var urlBuilder = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)!
        urlBuilder.queryItems = query
        let reqURL = urlBuilder.url!

        // Create URLRequest and set headers
        var req = URLRequest(url: reqURL)
        req.httpMethod = method.rawValue
        req.setValue(DiscordKitConfig.default.isBot ? "Bot \(token)" : token, forHTTPHeaderField: "authorization")
        req.setValue(DiscordKitConfig.default.baseURL.absoluteString, forHTTPHeaderField: "origin")

        // These headers are to match headers present in actual requests from the official client
        // req.setValue("?0", forHTTPHeaderField: "sec-ch-ua-mobile") // The day this runs on iOS...
        // req.setValue("macOS", forHTTPHeaderField: "sec-ch-ua-platform") // We only run on macOS
        // The top 2 headers are only sent when running in browsers
        req.setValue(DiscordKitConfig.default.userAgent, forHTTPHeaderField: "user-agent")
        req.setValue("cors", forHTTPHeaderField: "sec-fetch-mode")
        req.setValue("same-origin", forHTTPHeaderField: "sec-fetch-site")
        req.setValue("empty", forHTTPHeaderField: "sec-fetch-dest")

        req.setValue(Locale.englishUS.rawValue, forHTTPHeaderField: "x-discord-locale")
        req.setValue("bugReporterEnabled", forHTTPHeaderField: "x-debug-options")
        guard let superEncoded = try? DiscordREST.encoder.encode(DiscordKitConfig.default.properties) else {
            assertionFailure("Couldn't encode super properties for request")
            throw RequestError.superEncodeFailure
        }
        req.setValue(superEncoded.base64EncodedString(), forHTTPHeaderField: "x-super-properties")

        if !attachments.isEmpty {
            // Exact boundary format used by Electron (WebKit) in Discord Desktop
            let boundary = "----WebKitFormBoundary\(String.random(count: 16))"
            req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
            req.httpBody = DiscordREST.createMultipartBody(with: body, boundary: boundary, attachments: attachments)
        } else if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "content-type")
            req.httpBody = body
        }

        // Make request
        guard let (data, response) = try? await DiscordREST.session.data(for: req),
              let httpResponse = response as? HTTPURLResponse else {
            throw RequestError.invalidResponse
        }
        guard httpResponse.statusCode / 100 == 2 else { // Check if status code is 2**
            Self.log.error("Response status code not 2xx", metadata: ["res.statusCode": "\(httpResponse.statusCode)"])
            Self.log.debug("Raw response: \(String(decoding: data, as: UTF8.self))")
            throw RequestError.unexpectedResponseCode(httpResponse.statusCode)
        }

        return data
    }

    /// Make a `GET` request to the Discord REST API
    ///
    /// Wrapper method for `makeRequest()` to make a GET request.
    ///
    /// - Parameters:
    ///   - path: API endpoint path relative to `GatewayConfig.restBase`
    ///  (passed canonically to `makeRequest()`)
    ///   - query: Array of URL query items (passed canonically to `makeRequest()`)
    ///
    /// - Returns: Struct of response conforming to Decodable, or nil
    /// if the request failed or the response couldn't be JSON-decoded.
    func getReq<T: Decodable>(
        path: String,
        query: [URLQueryItem] = []
    ) async throws -> T {
        // This helps debug JSON decoding errors
        let respData = try await makeRequest(path: path, query: query)
        do {
            return try DiscordREST.decoder.decode(T.self, from: respData)
        } catch {
            throw RequestError.jsonDecodingError(error: error)
        }
    }

    /// Make a `POST` request to the Discord REST API
    func postReq<D: Decodable, B: Encodable>(
        path: String,
        body: B? = nil,
        attachments: [URL] = []
    ) async throws -> D {
        let payload = body != nil ? try DiscordREST.encoder.encode(body) : nil
        let respData = try await makeRequest(
            path: path,
            attachments: attachments,
            body: payload,
            method: .post
        )
        do {
            return try DiscordREST.decoder.decode(D.self, from: respData)
        } catch {
            throw RequestError.jsonDecodingError(error: error)
        }
    }

    /// Make a `POST` request to the Discord REST API
    ///
    /// For endpoints that returns a 204 empty response
    func postReq<B: Encodable>(
        path: String,
        body: B
    ) async throws {
        let payload = try DiscordREST.encoder.encode(body)
        _ = try await makeRequest(
            path: path,
            body: payload,
            method: .post
        )
    }

    /// Make a `POST` request to the Discord REST API, for endpoints
    /// that both require no payload and returns a 204 empty response
    func postReq(path: String) async throws {
        _ = try await makeRequest(
            path: path,
            body: nil,
            method: .post
        )
    }

    /// Make a `PUT` request to the Discord REST API
    func putReq<B: Encodable, Response: Decodable>(
        path: String,
        body: B
    ) async throws -> Response {
        let payload = try DiscordREST.encoder.encode(body)
        let data = try await makeRequest(
            path: path,
            body: payload,
            method: .put
        )
        do {
            return try DiscordREST.decoder.decode(Response.self, from: data)
        } catch {
            throw RequestError.jsonDecodingError(error: error)
        }
    }

    /// Make a `PUT` request to the Discord REST API
    ///
    /// For endpoints that returns a 204 empty response
    func putReq<B: Encodable>(
        path: String,
        body: B
    ) async throws {
        let payload = try DiscordREST.encoder.encode(body)
        _ = try await makeRequest(
            path: path,
            body: payload,
            method: .put
        )
    }

    /// Make a `PUT` request to the Discord REST API
    ///
    /// For endpoints that returns a 204 empty response and doesn't have any body
    func putReq(
        path: String
    ) async throws {
        _ = try await makeRequest(
            path: path,
            body: nil,
            method: .put
        )
    }

    /// Make a `DELETE` request to the Discord REST API
    func deleteReq(path: String) async throws {
        _ = try await makeRequest(path: path, method: .delete)
    }

    /// Make a `PATCH` request to the Discord REST API
    ///
    /// Getting the response from PATCH requests aren't implemented
    /// as their response is usually not required
    func patchReq<B: Encodable>(
        path: String,
        body: B
    ) async throws {
        let payload: Data?
        payload = try? DiscordREST.encoder.encode(body)
        _ = try await makeRequest(
            path: path,
            body: payload,
            method: .patch
        )
    }

    func patchReq(path: String) async throws {
        _ = try await makeRequest(path: path, body: nil, method: .patch)
    }
}
