//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Егор Свистушкин on 04.12.2022.
//

import Foundation


class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private var alertPresenter: AlertPresenter = AlertPresenter()

    weak var delegate: QuestionFactoryDelegate?
    
    
    init(delegate: QuestionFactoryDelegate? = nil, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageUrl)
            } catch {
//                Эта штука под вопросом, должна выскакивать ошибка, если не удалось загрузить данные
                let viewModel = AlertModel(title: "Ошибка!", message: "Failed to load image", buttonText: "Попробовать ещё раз") { [weak self] in
                    guard let self = self else { return }
                    self.loadData()
                }
                self.alertPresenter.show(quiz: viewModel)
                
                //
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRating = (6...9).randomElement()
            //Я удалил в сториборде текст с вопросом, чтобы не было видно, что он обновляется при загрузке вопроса)
            let text = "Рейтинг этого фильма больше чем \(randomRating ?? 7)?"
            let correctAnswer = rating > Float(randomRating ?? 7)
            
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
