//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Михаил Иванов on 24.04.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
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

    // MARK: - Core Data Saving support
    func fetchData(completion: @escaping([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let task = try persistentContainer.viewContext.fetch(fetchRequest)
            completion(task)
        } catch let error {
            print("Failed to fetch data", error)
        }
        return
    }
    
    func deleteData(_ data: Task) {
        persistentContainer.viewContext.delete(data)
    }
    
    func save(completion: @escaping(Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return }
        
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return }
        
        completion(task)
    }
    
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
}
