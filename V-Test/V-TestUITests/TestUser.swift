//
//  TestUser.swift
//  V-TestUITests
//
//  Created by mac on 05/04/2021.
//

import XCTest

class TestUser: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    // Tet the ability to go back and fourth from a UserPage
    func testExample() throws {
        // Ensure time to load data, even on low network
        sleep(2)
        
        // Click on the first element found (a user cell)
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()

        // Tap navigation back button
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        let predicate = NSPredicate(format: "label BEGINSWITH 'Explore Albums'")
        let element = app.staticTexts.element(matching: predicate)

        XCTAssertFalse(element.exists)
    }
}
