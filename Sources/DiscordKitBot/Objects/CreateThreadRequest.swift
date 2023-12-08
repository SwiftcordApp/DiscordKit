struct CreateThreadRequest: Codable {
    let name: String
    let auto_archive_duration: Int?
    let rate_limit_per_user: Int?
}
