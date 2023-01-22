//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Егор Свистушкин on 22.01.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func show(quiz step: QuizStepViewModel)
    
    func highlightBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func enableButtons()
    func disableButtons()
    
    func clearHighlighBorder()
    
    func showResultMessage()
}
