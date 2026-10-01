import XCTest
@testable import LinktreeCore

final class ProfileTests: XCTestCase {
    func testHandleRules() throws {
        XCTAssertEqual(try LinkRules.normalizeHandle(" @Book.Chaowalit "), "book.chaowalit")
        for bad in ["ab", ".book", "book.", "bo..ok", "book!", String(repeating: "a", count: 31), "bo@ok"] {
            XCTAssertThrowsError(try LinkRules.normalizeHandle(bad), bad)
        }
    }

    func testURLRules() throws {
        XCTAssertEqual(try LinkRules.parseURL("bookchaowalit.com").absoluteString, "https://bookchaowalit.com")
        XCTAssertEqual(try LinkRules.parseURL("mailto:hi@example.com").scheme, "mailto")
        XCTAssertEqual(try LinkRules.parseURL("tel:+66812345678").scheme, "tel")
        for bad in ["http://insecure.example", "javascript:alert(1)", "localhost", "https://", "  "] {
            XCTAssertThrowsError(try LinkRules.parseURL(bad), bad)
        }
    }

    func testUTMIsAddedOnceAndOnlyToHttps() throws {
        let url = try LinkRules.parseURL("https://shop.example/p?id=7&utm_source=ig")
        let tagged = LinkRules.withUTM(url, source: "linktree")
        let items = URLComponents(url: tagged, resolvingAgainstBaseURL: false)?.queryItems ?? []
        XCTAssertEqual(items.map(\.name), ["id", "utm_source", "utm_medium"])
        XCTAssertEqual(items.first { $0.name == "utm_source" }?.value, "ig")
        let mail = try LinkRules.parseURL("mailto:a@b.co")
        XCTAssertEqual(LinkRules.withUTM(mail, source: "x"), mail)
    }

    func testLinksScheduleOrderAndStats() throws {
        var p = try Profile(handle: "book", displayName: "Book")
        let site = try p.addLink(title: " Website ", url: "bookchaowalit.com")
        let promo = try p.addLink(title: "Promo", url: "https://promo.example")
        XCTAssertThrowsError(try p.addLink(title: " ", url: "a.example")) { XCTAssertEqual($0 as? ProfileError, .emptyTitle) }
        XCTAssertEqual(site.title, "Website")

        try p.move(promo.id, to: 0)
        XCTAssertEqual(p.links.map(\.title), ["Promo", "Website"])

        try p.setEnabled(promo.id, false)
        let now = Date(timeIntervalSince1970: 1_000)
        XCTAssertEqual(p.visibleLinks(at: now).map(\.title), ["Website"])

        p.recordView(); p.recordView(); p.recordView(); p.recordView()
        try p.recordClick(site.id)
        XCTAssertEqual(p.clickThroughRate(site.id), 25, accuracy: 1e-9)
        XCTAssertEqual(p.clickThroughRate(UUID()), 0)
        XCTAssertThrowsError(try p.recordClick(UUID()))
    }

    func testScheduleWindow() throws {
        let start = Date(timeIntervalSince1970: 100)
        let end = Date(timeIntervalSince1970: 200)
        let link = ProfileLink(title: "Sale", url: try LinkRules.parseURL("sale.example"), visibleFrom: start, visibleUntil: end)
        XCTAssertFalse(link.isVisible(at: Date(timeIntervalSince1970: 99)))
        XCTAssertTrue(link.isVisible(at: start))
        XCTAssertFalse(link.isVisible(at: end))
    }
}
