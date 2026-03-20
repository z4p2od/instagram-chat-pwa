import Foundation

enum InstagramChatConstants {
    static let startDMInboxURL = URL(string: "https://www.instagram.com/direct/inbox/")!

    static let allowedHosts: Set<String> = [
        "www.instagram.com",
        "instagram.com",
    ]

    /// Once we reach a `/direct/...` URL, we will block navigation to anything else.
    static let dmPathPrefix = "/direct"

    /// Login / auth redirects must be allowed so users can authenticate inside the wrapper.
    static let authPathPrefixes: [String] = [
        "/accounts",
        "/challenge",
        "/oauth",
        "/privacy",
        "/terms",
        "/about",
        "/help",
    ]

    static let fallbackURL = URL(string: "https://www.instagram.com/direct/inbox/")!
}

