//
//  GatewayIncomingTests.swift
//

import XCTest
@testable import DiscordKitCore

final class GatewayIncomingTests: XCTestCase {
    func testUnknownOpcodeDecodesEnvelope() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":123,"s":42,"t":null,"d":{"ignored":true}}
        """)

        XCTAssertEqual(incoming.opcode, .unknown)
        XCTAssertEqual(incoming.seq, 42)
        assertUnknown(incoming.data)
    }

    func testUnknownDispatchEventDecodesEnvelope() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":43,"t":"NEW_GATEWAY_EVENT","d":{"ignored":true}}
        """)

        XCTAssertEqual(incoming.opcode, .dispatchEvent)
        XCTAssertEqual(incoming.seq, 43)
        XCTAssertNil(incoming.type)
        assertUnknown(incoming.data)
    }

    func testKnownDispatchDecodeFailurePreservesEnvelope() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":44,"t":"MESSAGE_CREATE","d":{}}
        """)

        XCTAssertEqual(incoming.opcode, .dispatchEvent)
        XCTAssertEqual(incoming.seq, 44)
        XCTAssertEqual(incoming.type, .messageCreate)
        assertUnknown(incoming.data)
    }

    func testQOSHeartbeatEncodesExplicitNulls() throws {
        let payload = GatewayOutgoing(
            opcode: .qosHeartbeat,
            data: GatewayQOSHeartbeat(seq: nil, qos: nil)
        )
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])

        XCTAssertEqual(object["op"] as? Int, 40)
        XCTAssertTrue(data["seq"] is NSNull)
        XCTAssertTrue(data["qos"] is NSNull)
    }

    func testUserIdentifyPayloadMatchesOfficialShape() throws {
        let originalConfig = DiscordKitConfig.default
        DiscordKitConfig.default = DiscordKitConfig()
        defer { DiscordKitConfig.default = originalConfig }

        let socket = RobustWebSocket(token: "token")
        let payload = GatewayOutgoing(opcode: .identify, data: socket.getIdentify())
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])
        let properties = try XCTUnwrap(data["properties"] as? [String: Any])
        let clientState = try XCTUnwrap(data["client_state"] as? [String: Any])
        let guildVersions = try XCTUnwrap(clientState["guild_versions"] as? [String: Any])

        XCTAssertEqual(object["op"] as? Int, 2)
        XCTAssertEqual(data["token"] as? String, "token")
        XCTAssertEqual(data["compress"] as? Bool, false)
        XCTAssertEqual(data["capabilities"] as? Int, 1_734_653)
        XCTAssertNil(data["intents"])
        XCTAssertTrue(guildVersions.isEmpty)
        XCTAssertEqual(properties["client_app_state"] as? String, "focused")
        XCTAssertEqual(properties["is_fast_connect"] as? Bool, false)
        XCTAssertEqual(properties["gateway_connect_reasons"] as? String, "")
        XCTAssertTrue(properties["client_event_source"] is NSNull)
        XCTAssertEqual(Set(properties.keys), expectedIdentifyPropertyKeys)
        XCTAssertNil(properties["client_version"])
        XCTAssertNil(properties["os_arch"])
        XCTAssertNil(properties["app_arch"])
        XCTAssertNil(properties["native_build_number"])
    }

    func testSuperPropertiesMatchOfficialWebShape() throws {
        let properties = GatewayConnProperties(
            browser: "Chrome",
            release_channel: "stable",
            os_version: "10.15.7",
            system_locale: "en-US",
            client_build_number: 556_969,
            browser_user_agent: "Mozilla/5.0 Chrome/149.0.0.0 Safari/537.36",
            browser_version: "149.0.0.0",
            referrer: "https://example.com/path",
            utm_source: "newsletter",
            utm_medium: "email",
            utm_campaign: "campaign",
            utm_content: "button",
            utm_term: "discord",
            search_engine: "google",
            mp_keyword: "chat",
            referrer_current: "https://current.example/path",
            utm_source_current: "current-newsletter",
            utm_medium_current: "current-email",
            utm_campaign_current: "current-campaign",
            utm_content_current: "current-button",
            utm_term_current: "current-discord",
            search_engine_current: "duckduckgo",
            mp_keyword_current: "current-chat",
            client_launch_id: "00000000-0000-4000-8000-000000000000",
            launch_signature: "11111111-1111-4111-8111-111111111111",
            client_heartbeat_session_id: "22222222-2222-4222-8222-222222222222"
        )
        let object = try encodeObject(properties)

        XCTAssertEqual(Set(object.keys), expectedSuperPropertyKeysIncludingOptionals)
        XCTAssertEqual(object["browser"] as? String, "Chrome")
        XCTAssertEqual(object["device"] as? String, "")
        XCTAssertEqual(object["release_channel"] as? String, "stable")
        XCTAssertEqual(object["client_build_number"] as? Int, 556_969)
        XCTAssertEqual(object["referring_domain"] as? String, "example.com")
        XCTAssertEqual(object["referring_domain_current"] as? String, "current.example")
        XCTAssertEqual(object["launch_signature"] as? String, "11111111-1111-4111-8111-111111111111")
        XCTAssertEqual(object["client_app_state"] as? String, "unfocused")
        XCTAssertEqual(object["client_heartbeat_session_id"] as? String, "22222222-2222-4222-8222-222222222222")
        XCTAssertTrue(object["client_event_source"] is NSNull)
        XCTAssertNil(object["client_version"])
        XCTAssertNil(object["os_arch"])
        XCTAssertNil(object["app_arch"])
        XCTAssertNil(object["native_build_number"])
    }

    func testDefaultSuperPropertiesUseCapturedWebClientValues() throws {
        let properties = try encodeObject(DiscordKitConfig().properties)
        let launchID = try XCTUnwrap(properties["client_launch_id"] as? String)
        let launchSignature = try XCTUnwrap(properties["launch_signature"] as? String)

        XCTAssertEqual(properties["browser"] as? String, "Chrome")
        XCTAssertEqual(properties["device"] as? String, "")
        XCTAssertEqual(properties["system_locale"] as? String, "en-US")
        XCTAssertEqual(properties["has_client_mods"] as? Bool, false)
        XCTAssertEqual(properties["browser_user_agent"] as? String, "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36")
        XCTAssertEqual(properties["browser_version"] as? String, "149.0.0.0")
        XCTAssertEqual(properties["os_version"] as? String, "10.15.7")
        XCTAssertEqual(properties["referrer"] as? String, "")
        XCTAssertEqual(properties["referring_domain"] as? String, "")
        XCTAssertEqual(properties["referrer_current"] as? String, "")
        XCTAssertEqual(properties["referring_domain_current"] as? String, "")
        XCTAssertEqual(properties["release_channel"] as? String, "stable")
        XCTAssertEqual(properties["client_build_number"] as? Int, 556_969)
        XCTAssertTrue(properties["client_event_source"] is NSNull)
        XCTAssertEqual(launchID, launchID.lowercased())
        XCTAssertEqual(launchSignature, launchSignature.lowercased())
        XCTAssertEqual(properties["client_app_state"] as? String, "unfocused")
        XCTAssertFalse(properties.keys.contains("utm_source"))
        XCTAssertFalse(properties.keys.contains("search_engine"))
        XCTAssertFalse(properties.keys.contains("client_heartbeat_session_id"))
    }

    func testDiscordKitConfigUsesLaunchIdentityOverrides() throws {
        let launchID = "00000000-0000-4000-8000-000000000000"
        let signature = "0f0e0d0c-030a-4108-8706-050402020100"
        let properties = try encodeObject(
            DiscordKitConfig(clientLaunchID: launchID, launchSignature: signature).properties
        )

        XCTAssertEqual(properties["client_launch_id"] as? String, launchID)
        XCTAssertEqual(properties["launch_signature"] as? String, signature)
    }

    func testLaunchIDsAreReusedAcrossPropertyInstances() throws {
        let first = try encodeObject(GatewayConnProperties())
        let second = try encodeObject(GatewayConnProperties())
        let firstLaunchID = try XCTUnwrap(first["client_launch_id"] as? String)
        let secondLaunchID = try XCTUnwrap(second["client_launch_id"] as? String)
        let firstLaunchSignature = try XCTUnwrap(first["launch_signature"] as? String)
        let secondLaunchSignature = try XCTUnwrap(second["launch_signature"] as? String)

        XCTAssertEqual(firstLaunchID, secondLaunchID)
        XCTAssertEqual(firstLaunchSignature, secondLaunchSignature)
    }

    func testFastConnectIdentifyPropertiesOmitMainGatewayFields() throws {
        let properties = GatewayConnProperties(
            client_launch_id: "00000000-0000-4000-8000-000000000000"
        ).addingGatewayIdentifyFields(
            clientAppState: nil,
            isFastConnect: true,
            gatewayConnectReasons: nil,
            installationID: "installation"
        )
        let object = try encodeObject(properties)

        XCTAssertEqual(object["is_fast_connect"] as? Bool, true)
        XCTAssertEqual(object["installation_id"] as? String, "installation")
        XCTAssertEqual(object["client_app_state"] as? String, "unfocused")
        XCTAssertNil(object["gateway_connect_reasons"])
        XCTAssertEqual(Set(object.keys), expectedSuperPropertyKeys.union(["is_fast_connect", "installation_id"]))
    }

    private func decodeGatewayIncoming(_ json: String) throws -> GatewayIncoming {
        try DiscordREST.decoder.decode(GatewayIncoming.self, from: Data(json.utf8))
    }

    private func encodePayloadObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        try encodeObject(value)
    }

    private func encodeObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try DiscordREST.encoder.encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func assertUnknown(
        _ data: GatewayIncoming.Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .unknown = data else {
            XCTFail("Expected unknown gateway data, got \(data)", file: file, line: line)
            return
        }
    }

    private var expectedIdentifyPropertyKeys: Set<String> {
        expectedSuperPropertyKeys.union([
            "client_app_state",
            "is_fast_connect",
            "gateway_connect_reasons"
        ])
    }

    private var expectedSuperPropertyKeys: Set<String> {
        [
            "os",
            "browser",
            "device",
            "system_locale",
            "has_client_mods",
            "browser_user_agent",
            "browser_version",
            "os_version",
            "referrer",
            "referring_domain",
            "referrer_current",
            "referring_domain_current",
            "release_channel",
            "client_build_number",
            "client_event_source",
            "client_launch_id",
            "launch_signature",
            "client_app_state"
        ]
    }

    private var expectedSuperPropertyKeysIncludingOptionals: Set<String> {
        expectedSuperPropertyKeys.union([
            "utm_source",
            "utm_medium",
            "utm_campaign",
            "utm_content",
            "utm_term",
            "search_engine",
            "mp_keyword",
            "utm_source_current",
            "utm_medium_current",
            "utm_campaign_current",
            "utm_content_current",
            "utm_term_current",
            "search_engine_current",
            "mp_keyword_current",
            "client_heartbeat_session_id"
        ])
    }
}
