//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Егор Свистушкин on 25.12.2022.
//

import UIKit

final class AlertPresenter {
    
    weak var viewController: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.viewController = delegate
    }
    
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            result.completion()
        }
        alert.view.accessibilityIdentifier = "Alert"
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
}
