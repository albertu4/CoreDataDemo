//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        
        StorageManager.shared.fetchData { tasks in
            self.taskList = tasks
        }
    }
    
    //MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}

// MARK: - AlertController
extension TaskListViewController {
    
    private func showAlert(with title: String, and message: String, placeholder: String, previousTask: String, index: Int?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty, alert.textFields?.first?.text != previousTask else { return }
            
            if index == nil {
                StorageManager.shared.save { task in
                    task.title = taskName
                    self.taskList.append(task)
                    
                    let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
                    self.tableView.insertRows(at: [cellIndex], with: .automatic)
                }
            } else {
                StorageManager.shared.save { task in
                    self.taskList[index ?? 0].title = taskName
                    let cellIndex = IndexPath(row: index ?? 0, section: 0)
                    self.tableView.reloadRows(at: [cellIndex], with: .automatic)
                }
            }
            StorageManager.shared.saveContext()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = previousTask
        }
        present(alert, animated: true)
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task",
                  and: "What do you want to do?",
                  placeholder: "New Task",
                  previousTask: "",
                  index: nil)
    }
    
    private func editTask(previousTask: String, index: Int) {
        showAlert(with: "Update Task",
                  and: "What do you want to do?",
                  placeholder: "Task",
                  previousTask: previousTask,
                  index: index)
    }
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editTask(previousTask: taskList[indexPath.row].title ?? "", index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let task = taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            StorageManager.shared.deleteData(task)
        }
    }
}
