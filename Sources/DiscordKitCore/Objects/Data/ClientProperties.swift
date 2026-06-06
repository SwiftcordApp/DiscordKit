//
//  ClientProperties.swift
//

import Foundation

public enum PropertiesOS: String, Codable {
    case macOS = "Mac OS X"
    case linux = "Linux"
    case iOS = "iOS"
    case windows = "Windows"
    case android = "Android"

    public static var current: Self {
        #if os(macOS) || targetEnvironment(macCatalyst)
            .macOS
        #elseif os(iOS)
            .iOS
        #else
            .linux
        #endif
    }
}

/// Client properties shared by REST `x-super-properties` and Gateway identify.
///
/// REST requests populate the shared base fields. Gateway identify uses the
/// same flat object with Gateway-only lifecycle fields populated or overwritten.
public struct GatewayConnProperties: OutgoingGatewayData {
    public init(
        os: PropertiesOS = .current, // swiftlint:disable:this identifier_name
        browser: String = "Chrome",
        device: String? = "",
        release_channel: String? = "stable",
        client_version: String? = nil,
        os_version: String? = "",
        os_arch: String? = "arm64",
        system_locale: String? = Locale.englishUS.rawValue,
        client_build_number: Int? = 556_969,
        has_client_mods: Bool = false,
        browser_user_agent: String = "",
        browser_version: String = "",
        referrer: String = "",
        referring_domain: String? = nil,
        utm_source: String? = nil,
        utm_medium: String? = nil,
        utm_campaign: String? = nil,
        utm_content: String? = nil,
        utm_term: String? = nil,
        search_engine: String? = nil,
        mp_keyword: String? = nil,
        referrer_current: String? = nil,
        referring_domain_current: String? = nil,
        utm_source_current: String? = nil,
        utm_medium_current: String? = nil,
        utm_campaign_current: String? = nil,
        utm_content_current: String? = nil,
        utm_term_current: String? = nil,
        search_engine_current: String? = nil,
        mp_keyword_current: String? = nil,
        client_event_source: String? = nil,
        client_launch_id: String? = DiscordKitConfig.clientLaunchID,
        launch_signature: String? = DiscordKitConfig.launchSignature,
        client_app_state: String? = "unfocused",
        client_heartbeat_session_id: String? = nil,
        is_fast_connect: Bool? = nil,
        gateway_connect_reasons: String? = nil,
        installation_id: String? = nil
    ) {
        self.os = os
        self.browser = browser
        self.device = device ?? ""
        self.system_locale = system_locale ?? Locale.englishUS.rawValue
        self.has_client_mods = has_client_mods
        self.browser_user_agent = browser_user_agent
        self.browser_version = browser_version
        self.os_version = os_version ?? ""
        self.referrer = referrer
        self.referring_domain = referring_domain ?? Self.referringDomain(from: referrer)
        self.utm_source = utm_source
        self.utm_medium = utm_medium
        self.utm_campaign = utm_campaign
        self.utm_content = utm_content
        self.utm_term = utm_term
        self.search_engine = search_engine
        self.mp_keyword = mp_keyword
        let currentReferrer = referrer_current ?? referrer
        self.referrer_current = currentReferrer
        self.referring_domain_current = referring_domain_current ?? Self.referringDomain(from: currentReferrer)
        self.utm_source_current = utm_source_current
        self.utm_medium_current = utm_medium_current
        self.utm_campaign_current = utm_campaign_current
        self.utm_content_current = utm_content_current
        self.utm_term_current = utm_term_current
        self.search_engine_current = search_engine_current
        self.mp_keyword_current = mp_keyword_current
        self.release_channel = release_channel ?? "stable"
        self.client_build_number = client_build_number ?? 556_969
        _client_event_source = NullEncodable(wrappedValue: client_event_source)
        self.client_launch_id = client_launch_id ?? DiscordKitConfig.clientLaunchID
        _launch_signature = NullEncodable(wrappedValue: launch_signature)
        self.client_app_state = client_app_state
        self.client_heartbeat_session_id = client_heartbeat_session_id
        self.is_fast_connect = is_fast_connect
        self.gateway_connect_reasons = gateway_connect_reasons
        self.installation_id = installation_id
        _ = client_version
        _ = os_arch
    }

    /// OS the client is running on.
    let os: PropertiesOS // swiftlint:disable:this identifier_name
    /// Browser name. Observed web values are browser names such as `Chrome`.
    let browser: String
    /// Browser-derived device string. The official web client sends an empty string when no device is derived.
    let device: String
    /// Release channel of target official client.
    let release_channel: String
    /// OS version derived by the browser platform parser.
    let os_version: String
    /// System locale.
    let system_locale: String
    /// Build number of target official client.
    let client_build_number: Int

    let has_client_mods: Bool
    let browser_user_agent: String
    let browser_version: String
    let referrer: String
    let referring_domain: String
    let utm_source: String?
    let utm_medium: String?
    let utm_campaign: String?
    let utm_content: String?
    let utm_term: String?
    let search_engine: String?
    let mp_keyword: String?
    let referrer_current: String
    let referring_domain_current: String
    let utm_source_current: String?
    let utm_medium_current: String?
    let utm_campaign_current: String?
    let utm_content_current: String?
    let utm_term_current: String?
    let search_engine_current: String?
    let mp_keyword_current: String?
    @NullEncodable var client_event_source: String?
    let client_launch_id: String
    @NullEncodable var launch_signature: String?

    var client_app_state: String?
    var client_heartbeat_session_id: String?
    var is_fast_connect: Bool?
    var gateway_connect_reasons: String?
    var installation_id: String?

    func addingGatewayIdentifyFields(
        clientAppState: String?,
        isFastConnect: Bool,
        gatewayConnectReasons: String?,
        installationID: String?
    ) -> Self {
        var properties = self
        if let clientAppState = clientAppState {
            properties.client_app_state = clientAppState
        }
        properties.is_fast_connect = isFastConnect
        properties.gateway_connect_reasons = gatewayConnectReasons
        properties.installation_id = installationID
        return properties
    }

    private static func referringDomain(from referrer: String) -> String {
        guard let host = URL(string: referrer)?.host else { return "" }
        return host
    }
}
