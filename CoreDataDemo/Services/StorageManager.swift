//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Михаил Иванов on 24.04.2022.
//

import CoreData
import UIKit

class StorageManager {
    
    static let shared = StorageManager()
    
    var taskList: [Task] = []
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
        return taskList
    }
    
    func deleteData(at indexPath: IndexPath, tableView: UITableView) {
        let task = taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        persistentContainer.viewContext.delete(task)
        
        saveContext()
    }
    
    func save(_ taskName: String, tableView: UITableView) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return }
        
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return }
        
        task.title = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        saveContext()
    }
    
    func saveEdition(_ taskName: String, tableView: UITableView, index: Int) {
        taskList[index].title = taskName
        let cellIndex = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [cellIndex], with: .automatic)
        
        saveContext()
    }
}
