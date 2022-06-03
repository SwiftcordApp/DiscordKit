//
//  GetSuperProperties.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation

let iso8601 = { () -> ISO8601DateFormatter in
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime]
    return fmt
}()

let iso8601WithFractionalSeconds = { () -> ISO8601DateFormatter in
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return fmt
}()

public extension DiscordAPI {
    /// Populate a ``GatewayConnProperties`` struct with some constant
    /// values + some dynamic versions
    ///
    /// - Returns: Populated ``GatewayConnProperties``
	static func getSuperProperties() -> GatewayConnProperties {
		var systemInfo = utsname()
		uname(&systemInfo)

		// Ugly method to turn C char array into String
		func parseUname<T>(ptr: UnsafePointer<T>) -> String {
			ptr.withMemoryRebound(
				to: UInt8.self,
				capacity: MemoryLayout.size(ofValue: ptr)
			) { return String(cString: $0) }
		}

		let release = withUnsafePointer(to: systemInfo.release) {
			parseUname(ptr: $0)
		}
		// This should be called arch instead
		let machine = withUnsafePointer(to: systemInfo.machine) { parseUname(ptr: $0) }

		return GatewayConnProperties(
			os: "Mac OS X",
			browser: "Discord Client",
			release_channel: GatewayConfig.default.parity.releaseCh.rawValue,
			client_version: GatewayConfig.default.parity.version,
			os_version: release,
			os_arch: machine,
			system_locale: Locale.englishUS.rawValue,
			client_build_number: GatewayConfig.default.parity.buildNumber
		)
	}

    /// User agent to be sent along with all requests
    ///
    /// This is mainly to emulate the official clients to evade bans.
	static var userAgent: String {
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) discord/\(GatewayConfig.default.parity.version) Chrome/91.0.4472.164 Electron/\(GatewayConfig.default.parity.electronVersion) Safari/537.36"
	}

    static func encoder() -> JSONEncoder {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            let dateString = iso8601WithFractionalSeconds.string(from: date)
            try container.encode(dateString)
        })
        return enc
    }

    static func decoder() -> JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = iso8601.date(from: dateString) {
                return date
            }
            if let date = iso8601WithFractionalSeconds.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        })
        return dec
    }
}
