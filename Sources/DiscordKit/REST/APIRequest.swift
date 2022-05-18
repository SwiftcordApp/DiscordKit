//
//  APIRequest.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation
import DiscordKitCommon

/// Utility wrappers for easy request-making
public extension DiscordAPI {
    /// The few supported request methods
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
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
    static func makeRequest(
        path: String,
        query: [URLQueryItem] = [],
        attachments: [URL] = [],
        body: String? = nil,
        method: RequestMethod = .get
    ) async throws -> Data? {
        DiscordAPI.log.debug("\(method.rawValue): \(path)")
        
        guard let token = Keychain.load(key: "authToken") else { return nil }
        guard var apiURL = URL(string: GatewayConfig.default.restBase) else { return nil }
        apiURL.appendPathComponent(path, isDirectory: false)
        
        // Add query params (if any)
        var urlBuilder = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)
        urlBuilder?.queryItems = query
        guard let reqURL = urlBuilder?.url else { return nil }
        
        // Create URLRequest and set headers
        var req = URLRequest(url: reqURL)
        req.httpMethod = method.rawValue
        req.setValue(token, forHTTPHeaderField: "authorization")
        req.setValue(GatewayConfig.default.baseURL, forHTTPHeaderField: "origin")
        
        // These headers are to match headers present in actual requests from the official client
        // req.setValue("?0", forHTTPHeaderField: "sec-ch-ua-mobile") // The day this runs on iOS...
        // req.setValue("macOS", forHTTPHeaderField: "sec-ch-ua-platform") // We only run on macOS
        // The top 2 headers are only sent when running in browsers
        req.setValue(DiscordAPI.userAgent, forHTTPHeaderField: "user-agent")
        req.setValue("cors", forHTTPHeaderField: "sec-fetch-mode")
        req.setValue("same-origin", forHTTPHeaderField: "sec-fetch-site")
        req.setValue("empty", forHTTPHeaderField: "sec-fetch-dest")
        
        req.setValue(Locale.englishUS.rawValue, forHTTPHeaderField: "x-discord-locale")
        req.setValue("bugReporterEnabled", forHTTPHeaderField: "x-debug-options")
        guard let superEncoded = try? JSONEncoder().encode(getSuperProperties()) else {
            DiscordAPI.log.error("Couldn't encode super properties, something is seriously wrong")
            return nil
        }
        req.setValue(superEncoded.base64EncodedString(), forHTTPHeaderField: "x-super-properties")
        
        if !attachments.isEmpty {
            // Exact boundary format used by Electron (WebKit) in Discord Desktop
            let boundary = "----WebKitFormBoundary\(String.random(count: 16))"
            req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
            req.httpBody = createMultipartBody(with: body, boundary: boundary, attachments: attachments)
        } else if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "content-type")
            req.httpBody = body.data(using: .utf8)
        }
                
        // Make request
        let (data, response) = try await DiscordAPI.session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        guard httpResponse.statusCode / 100 == 2 else { // Check if status code is 2**
            log.warning("Status code is not 2xx: \(httpResponse.statusCode, privacy: .public)")
            log.warning("Response: \(String(decoding: data, as: UTF8.self), privacy: .public)")
            return nil
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
    static func getReq<T: Decodable>(
        path: String,
        query: [URLQueryItem] = []
    ) async -> T? {
        // This helps debug JSON decoding errors
        do {
            guard let d = try? await makeRequest(path: path, query: query)
            else { return nil }
            
            return try JSONDecoder().decode(T.self, from: d)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
    
    /// Make a `POST` request to the Discord REST API
    static func postReq<D: Decodable, B: Encodable>(
        path: String,
        body: B? = nil,
        attachments: [URL] = []
    ) async -> D? {        
        let p = body != nil ? try? JSONEncoder().encode(body) : nil
        guard let d = try? await makeRequest(
            path: path,
            attachments: attachments,
            body: p != nil ? String(decoding: p!, as: UTF8.self) : nil,
            method: .post
        )
        else { return nil }
        
        return try? JSONDecoder().decode(D.self, from: d)
    }
    
    /// Make a `POST` request to the Discord REST API, for endpoints
    /// that both require no payload and returns a 204 empty response
    static func emptyPostReq(path: String) async -> Bool {
        guard (try? await makeRequest(
            path: path,
            body: nil,
            method: .post
        )) != nil
        else { return false }
        return true
    }
    
    /// Make a `DELETE` request to the Discord REST API
    static func deleteReq(path: String) async -> Bool {
        return (try? await makeRequest(path: path, method: .delete)) != nil
    }
}
