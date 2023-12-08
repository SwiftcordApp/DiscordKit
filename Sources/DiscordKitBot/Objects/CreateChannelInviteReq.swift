struct CreateChannelInviteReq: Codable {
    let max_age: Int
    let max_users: Int
    let temporary: Bool
    let unique: Bool
}
