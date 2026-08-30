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
    enum RequestError: LocalizedError {
        case unexpectedResponseCode(_ code: Int)
        case invalidResponse
        case superEncodeFailure
        case jsonDecodingError(error: Error) // This is not strongly typed because it was simpler to just use one catch
        case genericError(reason: String)
        case networkError(error: Error)
        case apiError(statusCode: Int, discordCode: Int?, message: String?, retryAfter: TimeInterval?)

        public var errorDescription: String? {
            switch self {
            case .unexpectedResponseCode(let statusCode):
                Self.description(for: statusCode)
            case .invalidResponse:
                "Discord returned an invalid response."
            case .superEncodeFailure:
                "The app couldn't prepare the request to Discord."
            case .jsonDecodingError:
                "Discord returned data the app couldn't understand."
            case .genericError(let reason):
                reason
            case .networkError(let error):
                Self.description(for: error)
            case .apiError(let statusCode, _, let message, let retryAfter):
                if statusCode == 429 {
                    Self.rateLimitDescription(retryAfter: retryAfter)
                } else if [401, 403].contains(statusCode) {
                    Self.description(for: statusCode)
                } else if let message = message?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !message.isEmpty {
                    message.hasSuffix(".") ? message : "\(message)."
                } else {
                    Self.description(for: statusCode)
                }
            }
        }

        public var failureReason: String? {
            switch self {
            case .jsonDecodingError(let error), .networkError(let error):
                error.localizedDescription
            case .apiError(_, let discordCode?, _, _):
                "Discord error code \(discordCode)."
            default:
                nil
            }
        }

        private static func description(for statusCode: Int) -> String {
            switch statusCode {
            case 400:
                "Discord rejected the request."
            case 401:
                "Your Discord session has expired. Sign in again and retry."
            case 403:
                "You don't have permission to perform this action."
            case 404:
                "The requested item no longer exists."
            case 408:
                "Discord took too long to respond. Try again."
            case 429:
                rateLimitDescription(retryAfter: nil)
            case 500 ... 599:
                "Discord is having trouble completing requests right now. Try again later."
            default:
                "Discord couldn't complete the request (HTTP \(statusCode))."
            }
        }

        private static func description(for error: Error) -> String {
            guard let urlError = error as? URLError else {
                return "Couldn't connect to Discord."
            }
            switch urlError.code {
            case .notConnectedToInternet:
                return "You're offline. Check your internet connection and try again."
            case .timedOut:
                return "Discord took too long to respond. Try again."
            case .cancelled:
                return "The request was cancelled."
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .networkConnectionLost:
                return "Couldn't connect to Discord. Check your internet connection and try again."
            default:
                return "A network error prevented the request from reaching Discord."
            }
        }

        private static func rateLimitDescription(retryAfter: TimeInterval?) -> String {
            guard let retryAfter, retryAfter > 0 else {
                return "You're doing that too quickly. Try again shortly."
            }
            let seconds = max(1, Int(retryAfter.rounded(.up)))
            return "You're doing that too quickly. Try again in \(seconds) \(seconds == 1 ? "second" : "seconds")."
        }
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
        try await makeRequestWithResponse(
            path: path,
            query: query,
            attachments: attachments,
            body: body,
            method: method
        ).0
    }

    /// Make a Discord REST API request, returning the `HTTPURLResponse`
    ///
    /// Identical to `makeRequest()`, for endpoints that need to inspect the
    /// response status code or headers (e.g. message search's `202 Accepted`
    /// indexing responses with a `retry-after` header).
    func makeRequestWithResponse(
        path: String,
        query: [URLQueryItem] = [],
        attachments: [URL] = [],
        body: Data? = nil,
        method: RequestMethod = .get,
        allowsNonSuccessfulResponse: Bool = false
    ) async throws -> (Data, HTTPURLResponse) {
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
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await DiscordREST.session.data(for: req)
        } catch {
            throw RequestError.networkError(error: error)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RequestError.invalidResponse
        }
        guard allowsNonSuccessfulResponse || httpResponse.statusCode / 100 == 2 else {
            Self.log.error("Response status code not 2xx", metadata: ["res.statusCode": "\(httpResponse.statusCode)"])
            Self.log.debug("Raw response: \(String(decoding: data, as: UTF8.self))")
            if let response = try? Self.decoder.decode(DiscordAPIErrorResponse.self, from: data) {
                throw RequestError.apiError(
                    statusCode: httpResponse.statusCode,
                    discordCode: response.code,
                    message: response.message,
                    retryAfter: response.retryAfter
                )
            }
            throw RequestError.unexpectedResponseCode(httpResponse.statusCode)
        }

        return (data, httpResponse)
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
        query: [URLQueryItem] = [],
        body: B? = nil,
        attachments: [URL] = []
    ) async throws -> D {
        let payload = body != nil ? try DiscordREST.encoder.encode(body) : nil
        let respData = try await makeRequest(
            path: path,
            query: query,
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
        path: String,
        query: [URLQueryItem] = []
    ) async throws {
        _ = try await makeRequest(
            path: path,
            query: query,
            body: nil,
            method: .put
        )
    }

    /// Make a `DELETE` request to the Discord REST API
    func deleteReq(path: String, query: [URLQueryItem] = []) async throws {
        _ = try await makeRequest(path: path, query: query, method: .delete)
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

private struct DiscordAPIErrorResponse: Decodable {
    let code: Int?
    let message: String?
    let retryAfter: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case retryAfter = "retry_after"
    }
}
