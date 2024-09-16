//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Егор Свистушкин on 21.01.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader())
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory.loadData()
        viewController.showLoadingIndicator()
        
    }
    
///    Прячет индикатор загрузки, вызывает функцию requestNextQuestion
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
///     Вызывает функцию показа ошибки
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
///    Принимает на вход вопрос, далее конвертирует его при помощи convert и показывает по главному потоку
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
    
///    Проверяет, является ли вопрос последним
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
///    Проверяет, является ли вопрос корректным и добавляет +1 к счётчику правильных ответов, если тот верный
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
///    Функция выставляет значение текущего вопроса и кол-во правильных ответов на 0 и вызывает функцию requestNextQuestion
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
///    Функция прибавляет к индексу 1
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
///    Конвертация из структуры данных в структуру графическую
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
///    Выставляет didAnswer на true при нажатии кнопки да
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
///    Выставляет didAnswer на false при нажатии кнопки нет
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
///    Сверяет правильность ответа
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
///    Действия при ответе: рамка ответа(зелёный, красный), отключение кнопок и через время переход к следующему вопросу(или ответу) и отмена действий написаных ранее
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightBorder(isCorrectAnswer: isCorrect)
        viewController?.disableButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
            self.viewController?.enableButtons()
            self.viewController?.clearHighlighBorder()
        }
    }
    
///    Проверяет, последний ли это вопрос, если последний, то вызывает функцию показа последнего аллерта, если не последний, то переход на следующий вопрос
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            viewController?.showResultMessage()
            
        } else {
            switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
    
///    Генерирует строку сообщения для финального аллерта
    func getResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let currentGameResultsLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correctAnswers)/\(bestGame.totalAnswers)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultsLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }

}
