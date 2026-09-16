//
//  ProductSearchUITests.swift
//  CoolblueSHorenkoUITests
//
//  Created by Serhii Horenko on 16/09/2026.
//

import XCTest

final class ProductSearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testShowsAProductPerRow() {
        let app = XCUIApplication.launched(with: .products)

        XCTAssertTrue(app.firstRow.waitForExistence(timeout: timeout))
        XCTAssertEqual(app.productRows.count, 2)
    }

    @MainActor
    func testAProductRowShowsNamePriceRatingAndAvailability() {
        let app = XCUIApplication.launched(with: .products)
        XCTAssertTrue(app.firstRow.waitForExistence(timeout: timeout))

        let row = app.firstRow.label

        XCTAssertTrue(row.contains("Apple iPhone X 256GB Zilver"), row)
        XCTAssertTrue(row.contains("1.279"), row)
        XCTAssertTrue(row.contains("9,2"), row)
        XCTAssertTrue(row.contains("209"), row)
        XCTAssertTrue(row.contains("In stock"), row)
    }

    @MainActor
    func testAnUnavailableProductSaysSoInWordsNotOnlyInColour() {
        let app = XCUIApplication.launched(with: .products)
        XCTAssertTrue(app.firstRow.waitForExistence(timeout: timeout))

        let row = app.productRows.element(boundBy: 1).label

        XCTAssertTrue(row.contains("Not available"), row)
        // Zero reviews is no rating at all, rather than a nought-star product.
        XCTAssertFalse(row.contains("Rated"), row)
    }

    @MainActor
    func testShowsTheEmptyStateWhenTheShopReturnsNothing() {
        let app = XCUIApplication.launched(with: .empty)

        XCTAssertTrue(app.staticTexts["No products"].waitForExistence(timeout: timeout))
        XCTAssertEqual(app.productRows.count, 0)
    }

    @MainActor
    func testOffersRetryWhenTheConnectionFails() {
        let app = XCUIApplication.launched(with: .connectivity)

        XCTAssertTrue(app.staticTexts["Something went wrong"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["Try again"].exists)
    }

    @MainActor
    func testOffersNoRetryWhenRetryingCannotHelp() {
        let app = XCUIApplication.launched(with: .invalidData)

        XCTAssertTrue(app.staticTexts["Something went wrong"].waitForExistence(timeout: timeout))
        XCTAssertFalse(app.buttons["Try again"].exists)
    }

    @MainActor
    func testRetryLoadsTheProductsThatFailedTheFirstTime() {
        let app = XCUIApplication.launched(with: .failsThenSucceeds)

        let retry = app.buttons["Try again"]
        XCTAssertTrue(retry.waitForExistence(timeout: timeout))

        retry.tap()

        XCTAssertTrue(app.firstRow.waitForExistence(timeout: timeout))
        XCTAssertEqual(app.productRows.count, 2)
        XCTAssertFalse(app.staticTexts["Something went wrong"].exists)
    }

    private let timeout: TimeInterval = 10
}

extension XCUIApplication {
    fileprivate var firstRow: XCUIElement {
        productRows.element(boundBy: 0)
    }
}
