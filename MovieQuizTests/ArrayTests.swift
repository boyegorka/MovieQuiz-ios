//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Егор Свистушкин on 18.01.2023.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func getValueInRange() throws {
        //Given
        let array = [1, 1, 2, 3, 5]
        //When
        let value = array[safe: 2]
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func getValueOutOfRange() throws {
        //Given
        let array = [1, 1, 2, 3, 5]
        //When
        let value = array[safe: 20]
        //Then
        XCTAssertNil(value)
    }
}
