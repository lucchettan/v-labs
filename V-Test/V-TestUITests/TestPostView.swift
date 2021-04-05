//
//  TestPostView.swift
//  V-TestUITests
//
//  Created by mac on 05/04/2021.
//

import XCTest

class TestPostView: XCTestCase {
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

    
    // This test ensure we are able to navigate to:
    //      a User page,
    //      one of his Post
    //      the comments of this Post,
    //      and comment the Post
    func testExample() throws {
        // Ensure time to load data, even on low network
        sleep(2)
        
        // Click on the first element found
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
        
        //Click on the first item of the second list
        app.tables.element(boundBy: 1).cells.element(boundBy: 0).tap()
                app.buttons["SeeComments"].firstMatch.tap()
        
        // Ensure Time to load comments
        sleep(1)
        
        // Tap the close modal of themodal
        app.buttons["Close"].firstMatch.tap()
        
        // Fullfill the Form
        app.textFields["Enter Name"].tap()
        app.textFields["Enter Name"].typeText("Test")
        app.textFields["Enter Email"].tap()
        app.textFields["Enter Email"].typeText("TestingMail")
        app.textFields["Comment here"].tap()
        app.textFields["Comment here"].typeText("TestingComment")
        
        // Tap the button to add a comment
        app.buttons["AddComment"].tap()

        let predicate = NSPredicate(format: "label BEGINSWITH 'On the way!'")
        let element = app.staticTexts.element(matching: predicate)

        // Verify that the text from the success alert exists.
        XCTAssertTrue(element.exists)
        
        // Tap the alert Buton
        app.buttons["Ok"].tap()

        // Ensure the alert is dismissed
        XCTAssertFalse(app.buttons["Ok"].exists)
    }
}
