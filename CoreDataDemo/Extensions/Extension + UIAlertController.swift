//
//  Extension + UIAlertController.swift
//  CoreDataDemo
//
//  Created by Михаил Иванов on 13.10.2022.
//

import UIKit

extension UIAlertController {
    
    static func createAlertController(with title: String) -> UIAlertController {
        UIAlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
    }
    
    func action(task: Task?, completion: @escaping(String) -> Void) {
        let saveAction = UIAlertAction(title: "Save", style: .default) {_ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "Task"
            textField.text = task?.title
        }
        
    }
}
