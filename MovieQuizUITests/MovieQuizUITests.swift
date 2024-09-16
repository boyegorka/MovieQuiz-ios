//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Егор Свистушкин on 18.01.2023.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        app.launch()
        
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        try super.setUpWithError()
        app.terminate()
        app = nil
        
    }

    func testExample() throws {
        
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    func testYesButton() {
        sleep(5)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        sleep(2)

        app.buttons["Yes"].tap()
        print(app.buttons["Yes"])
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        sleep(1)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        sleep(1)

        print(indexLabel.staticTexts)
        sleep(1)

        XCTAssertEqual(indexLabel.label, "2/10")


    }
    
    func testNoButton() {
        sleep(5)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
        
    }
    
    func testShowAllert() {
        sleep(2)
        var timer = 0
        while timer != 10 {
            app.buttons["Yes"].tap()
            timer += 1
            sleep(2)
        }
        sleep(3)
        
        let alert = app.alerts["Alert"]
        print(alert)
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testNewGameStarts() {
        sleep(5)
        var timer = 0
        while timer != 10 {
            app.buttons["Yes"].tap()
            timer += 1
            sleep(2)
        }
        sleep(3)
        
        let alert = app.alerts["Alert"]
        
        alert.buttons.firstMatch.tap()
            
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        sleep(2)
        
        XCTAssertEqual(indexLabel.label, "1/10")
        
    }

    
}
