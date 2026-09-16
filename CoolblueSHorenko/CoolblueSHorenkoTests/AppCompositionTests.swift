//
//  AppCompositionTests.swift
//  CoolblueSHorenkoTests
//
//  Created by Serhii Horenko on 16/09/2026.
//

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
}
