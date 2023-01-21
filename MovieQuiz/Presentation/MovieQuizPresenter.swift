//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Егор Свистушкин on 21.01.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
        weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
        var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader())
    private var alertPresenter: AlertPresenter = AlertPresenter()
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
        questionFactory.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
//
//    func yesButtonClicked(_ sender: Any) {
//        guard let currentQuestion = currentQuestion else { return }
//        let givenAnswer = true
//        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
//
//    func noButtonClicked(_ sender: Any) {
//        guard let currentQuestion = currentQuestion else {return}
//        let givenAnswer = false
//        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n Количество сыграных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correctAnswers)/\(statisticService.bestGame.totalAnswers) (\(statisticService.bestGame.date.dateTimeString))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let viewModel = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else { return }
                self.restartGame()
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
            alertPresenter.show(quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            self.questionFactory.loadData()
        }
    }
    
    
}
