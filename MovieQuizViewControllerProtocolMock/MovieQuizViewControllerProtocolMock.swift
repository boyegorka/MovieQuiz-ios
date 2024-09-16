//
//  MovieQuizViewControllerProtocolMock.swift
//  MovieQuizViewControllerProtocolMock
//
//  Created by Егор Свистушкин on 22.01.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    func enableButtons() {
        
    }
    
    func disableButtons() {
        
    }
    
    func clearHighlighBorder() {
        
    }
    
    func showResultMessage() {
        
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    final class MovieQuizpresenterTests: XCTestCase {
        
        func testPresenterConvertMode() throws {
            
            let viewControllerMock = MovieQuizViewControllerProtocolMock()
            
            let realViewController = MovieQuizViewController()
            
            let sut = MovieQuizPresenter(viewController: viewControllerMock )

            let emptyData = Data()
            let question = QuizQuestion(image: emptyData, text: "Question text", correctAnswer: true)
            let viewModel = sut.convert(model: question)

            XCTAssertNotNil(viewModel.image)
            XCTAssertEqual(viewModel.question, "Question text")
            XCTAssertEqual(viewModel.questionNumber, "1/10")
        }
    }
    
}
