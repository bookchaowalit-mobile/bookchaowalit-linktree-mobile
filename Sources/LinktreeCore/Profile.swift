import Foundation

public enum ProfileError: Error, Equatable {
    case invalidHandle(String)
    case invalidURL(String)
    case emptyTitle
    case linkNotFound
}

public struct ProfileLink: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var url: URL
    public var enabled: Bool = true
    public var visibleFrom: Date?
    public var visibleUntil: Date?
    public var clicks: Int = 0

    public init(id: UUID = UUID(), title: String, url: URL, visibleFrom: Date? = nil, visibleUntil: Date? = nil) {
        self.id = id
        self.title = title
        self.url = url
        self.visibleFrom = visibleFrom
        self.visibleUntil = visibleUntil
    }

    /// Enabled and inside its optional schedule window (`visibleUntil` is exclusive).
    public func isVisible(at now: Date) -> Bool {
        guard enabled else { return false }
        if let from = visibleFrom, now < from { return false }
        if let until = visibleUntil, now >= until { return false }
        return true
    }
}

public enum LinkRules {
    /// 3–30 chars of a–z, 0–9, `_` and `.`; no leading/trailing or doubled dots. Lower-cases input.
    public static func normalizeHandle(_ raw: String) throws -> String {
        let h = raw.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: "@", with: "", options: .anchored)
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789_.")
        guard (3...30).contains(h.count), h.allSatisfy({ allowed.contains($0) }),
              !h.hasPrefix("."), !h.hasSuffix("."), !h.contains("..") else {
            throw ProfileError.invalidHandle(raw)
        }
        return h
    }

    /// Accepts https, mailto and tel links; bare domains get https. Rejects http and script schemes.
    public static func parseURL(_ raw: String) throws -> URL {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = s.lowercased()
        let candidate: String
        if lower.hasPrefix("https://") || lower.hasPrefix("mailto:") || lower.hasPrefix("tel:") {
            candidate = s
        } else if lower.contains(":") {
            throw ProfileError.invalidURL(raw)
        } else {
            candidate = "https://" + s
        }
        guard let url = URL(string: candidate), let scheme = url.scheme?.lowercased() else { throw ProfileError.invalidURL(raw) }
        if scheme == "https", (url.host ?? "").isEmpty || !(url.host ?? "").contains(".") { throw ProfileError.invalidURL(raw) }
        return url
    }

    /// Adds utm_source/utm_medium to https links unless already present.
    public static func withUTM(_ url: URL, source: String, medium: String = "linkinbio") -> URL {
        guard url.scheme?.lowercased() == "https",
              var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        var items = comps.queryItems ?? []
        if !items.contains(where: { $0.name == "utm_source" }) { items.append(URLQueryItem(name: "utm_source", value: source)) }
        if !items.contains(where: { $0.name == "utm_medium" }) { items.append(URLQueryItem(name: "utm_medium", value: medium)) }
        comps.queryItems = items
        return comps.url ?? url
    }
}

public struct Profile {
    public let handle: String
    public var displayName: String
    public private(set) var links: [ProfileLink] = []
    public private(set) var views: Int = 0

    public init(handle: String, displayName: String) throws {
        self.handle = try LinkRules.normalizeHandle(handle)
        self.displayName = displayName
    }

    @discardableResult
    public mutating func addLink(title: String, url: String) throws -> ProfileLink {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { throw ProfileError.emptyTitle }
        let link = ProfileLink(title: t, url: try LinkRules.parseURL(url))
        links.append(link)
        return link
    }

    public mutating func move(_ id: UUID, to position: Int) throws {
        guard let i = links.firstIndex(where: { $0.id == id }) else { throw ProfileError.linkNotFound }
        let link = links.remove(at: i)
        links.insert(link, at: max(0, min(position, links.count)))
    }

    public mutating func setEnabled(_ id: UUID, _ enabled: Bool) throws {
        guard let i = links.firstIndex(where: { $0.id == id }) else { throw ProfileError.linkNotFound }
        links[i].enabled = enabled
    }

    public func visibleLinks(at now: Date) -> [ProfileLink] { links.filter { $0.isVisible(at: now) } }

    public mutating func recordView() { views += 1 }

    public mutating func recordClick(_ id: UUID) throws {
        guard let i = links.firstIndex(where: { $0.id == id }) else { throw ProfileError.linkNotFound }
        links[i].clicks += 1
    }

    /// Click-through rate of a link in percent of profile views (0 when no views).
    public func clickThroughRate(_ id: UUID) -> Double {
        guard views > 0, let link = links.first(where: { $0.id == id }) else { return 0 }
        return Double(link.clicks) / Double(views) * 100
    }
}
