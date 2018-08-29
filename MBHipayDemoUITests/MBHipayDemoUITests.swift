//
//  MBHipayDemoUITests.swift
//  MBHipayDemoUITests
//
//  Created by Morgan on 28/08/2018.
//  Copyright © 2018 MB. All rights reserved.
//

import XCTest

class MBHipayDemoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testForm() {
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        let textField = elementsQuery.children(matching: .textField).element(boundBy: 0)
        textField.tap()
        textField.typeText("Nom Prenom")
        app/*@START_MENU_TOKEN@*/.buttons["Next:"]/*[[".keyboards",".buttons[\"Suivant\"]",".buttons[\"Next:\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let textField2 = elementsQuery.children(matching: .textField).element(boundBy: 1)
        textField2.typeText("4242424242424242")
        app/*@START_MENU_TOKEN@*/.buttons["Next:"]/*[[".keyboards",".buttons[\"Suivant\"]",".buttons[\"Next:\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let textField3 = elementsQuery.children(matching: .textField).element(boundBy: 2)
        textField3.typeText("0120")
        app/*@START_MENU_TOKEN@*/.buttons["Next:"]/*[[".keyboards",".buttons[\"Suivant\"]",".buttons[\"Next:\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let textField4 = elementsQuery.children(matching: .textField).element(boundBy: 3)
        textField4.typeText("444")
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".keyboards",".buttons[\"Terminé\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Pay"].tap()
        XCTAssert(app.alerts["Succès"].exists)
    }
    
}
