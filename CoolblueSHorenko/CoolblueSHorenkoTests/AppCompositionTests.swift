//
//  AppCompositionTests.swift
//  CoolblueSHorenkoTests
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking
import XCTest

@testable import CoolblueSHorenko

/// Covers the app target's only real logic: the composition root.
///
/// The layers themselves are tested inside their packages with Swift Testing. What can
/// only be tested here is the wiring — that `live()` picks the real client, and that the
/// endpoint constant composes into the URL the API actually expects. This target stays
/// on XCTest because it needs an app host.
final class AppCompositionTests: XCTestCase {

    func testSearchAPIBaseURLHasNoTrailingSlash() {
        // A trailing slash would make path composition produce "…/mobile-assignment//search".
        XCTAssertEqual(
            AppEndpoints.searchAPI.absoluteString,
            "https://bdk0sta2n0.execute-api.eu-west-1.amazonaws.com/mobile-assignment"
        )
    }

    @MainActor
    func testLiveEnvironmentInjectsTheRealHTTPClient() {
        let environment = AppEnvironment.live()

        XCTAssertTrue(environment.httpClient is URLSessionHTTPClient)
        XCTAssertEqual(environment.searchAPIBaseURL, AppEndpoints.searchAPI)
    }

    @MainActor
    func testComposingTheSearchScreenSendsNoRequest() {
        // Building a screen must be free. The fetch belongs to the view's .task, so that
        // a screen built and thrown away -- by a preview, or a navigation that is
        // cancelled -- costs nothing.
        let client = HTTPClientSpy()
        let environment = AppEnvironment(httpClient: client, searchAPIBaseURL: AppEndpoints.searchAPI)

        _ = ProductSearchComposer.makeSearchScreen(environment: environment)

        XCTAssertEqual(client.sendCount, 0)
    }
}

/// Counts requests without making any. The app target has no other need for a double,
/// so it lives beside the one test that uses it.
private final class HTTPClientSpy: HTTPClient, @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    var sendCount: Int {
        lock.withLock { count }
    }

    func send(_ request: HTTPRequest) async throws(HTTPError) -> HTTPResponse {
        lock.withLock { count += 1 }
        throw .connectivity
    }
}
