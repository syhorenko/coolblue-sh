//
//  CoolblueSHorenkoUITestsLaunchTests.swift
//  CoolblueSHorenkoUITests
//
//  Created by Serhii Horenko on 15/09/2026.
//

import XCTest

final class CoolblueSHorenkoUITestsLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication.launched(with: .products)

        XCTAssertTrue(app.productRows.element(boundBy: 0).waitForExistence(timeout: 10))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
