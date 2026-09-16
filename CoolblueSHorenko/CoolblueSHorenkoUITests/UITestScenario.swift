//
//  UITestScenario.swift
//  CoolblueSHorenkoUITests
//
//  Created by Serhii Horenko on 16/09/2026.
//

import XCTest

enum UITestScenario: String {
    case products
    case empty
    case connectivity
    case invalidData
    case failsThenSucceeds
}

/// Identifiers, copied from `ProductSearchAccessibility`.
enum AccessibilityID {
    static let list = "productList"
    static let row = "productRow"
}

extension XCUIApplication {
    /// Launches the app with the network replaced.
    static func launched(with scenario: UITestScenario) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TEST_SCENARIO"] = scenario.rawValue
        app.launch()
        return app
    }

    /// The product rows, in the order they are drawn.
    ///
    /// Buttons, not `.any`: each row is a `NavigationLink`, and the identifier set inside
    /// the row also surfaces on elements the link wraps it in. Matching the button matches
    /// each row exactly once.
    var productRows: XCUIElementQuery {
        buttons.matching(identifier: AccessibilityID.row)
    }
}
