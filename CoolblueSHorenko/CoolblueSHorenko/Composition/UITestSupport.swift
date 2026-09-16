//
//  UITestSupport.swift
//  CoolblueSHorenko
//
//  Created by Serhii Horenko on 16/09/2026.
//

#if DEBUG
import Foundation
import Networking

enum UITestSupport {

    /// Set by `XCUIApplication.launchEnvironment`.
    static let scenarioKey = "UI_TEST_SCENARIO"

    /// Mirrored by `UITestScenario` in the UI test target. A UI test runs out of process
    /// and links nothing from the app, so the two cannot share a type -- these raw values
    /// are the contract between them.
    enum Scenario: String {
        case products
        case empty
        case connectivity
        case invalidData
        case failsThenSucceeds
    }

    /// `nil` when the app was launched by a person, which is the only path a shipping
    /// build can take.
    static func environment(from processInfo: ProcessInfo = .processInfo) -> AppEnvironment? {
        guard let raw = processInfo.environment[scenarioKey],
              let scenario = Scenario(rawValue: raw) else {
            return nil
        }

        return AppEnvironment(
            httpClient: StubHTTPClient(scenario: scenario),
            searchAPIBaseURL: AppEndpoints.searchAPI
        )
    }
}

private final class StubHTTPClient: HTTPClient, @unchecked Sendable {
    private let scenario: UITestSupport.Scenario
    private let lock = NSLock()
    private var attempts = 0

    init(scenario: UITestSupport.Scenario) {
        self.scenario = scenario
    }

    func send(_ request: HTTPRequest) async throws(HTTPError) -> HTTPResponse {
        let attempt = lock.withLock {
            attempts += 1
            return attempts
        }

        switch scenario {
        case .products:
            return ok(StubPayload.twoProducts)

        case .empty:
            return ok(StubPayload.noProducts)

        case .connectivity:
            throw .connectivity

        case .invalidData:
            return ok(StubPayload.unreadable)

        case .failsThenSucceeds:
            // Lets a test prove that Try again actually retries, rather than that the
            // button merely exists.
            guard attempt > 1 else {
                throw HTTPError.connectivity
            }

            return ok(StubPayload.twoProducts)
        }
    }

    private func ok(_ json: String) -> HTTPResponse {
        HTTPResponse(statusCode: 200, body: Data(json.utf8))
    }
}

/// Replies shaped exactly like the live endpoint's, trimmed to what the screen renders.
private enum StubPayload {

    /// One in stock with a rating, one unavailable without -- the two rows that between
    /// them cover every branch in `ProductRow`.
    static let twoProducts = """
    {
      "products": [
        {
          "productId": 881732,
          "productName": "Apple iPhone X 256GB Zilver",
          "productImage": "https://image.coolblue.nl/300x750/products/1213950",
          "salesPriceIncVat": 1279,
          "availabilityState": 2,
          "reviewInformation": { "reviewSummary": { "reviewAverage": 9.2, "reviewCount": 209 } }
        },
        {
          "productId": 900213,
          "productName": "Apple iPhone X Siliconen Back Cover Zwart",
          "productImage": "https://image.coolblue.nl/300x750/products/1215085",
          "salesPriceIncVat": 24.99,
          "availabilityState": 3,
          "reviewInformation": { "reviewSummary": { "reviewAverage": 0, "reviewCount": 0 } }
        }
      ],
      "currentPage": 1,
      "pageCount": 1,
      "totalResults": 2
    }
    """

    static let noProducts = """
    { "products": [], "currentPage": 1, "pageCount": 1, "totalResults": 0 }
    """

    static let unreadable = """
    { "products": "not an array" }
    """
}
#endif
