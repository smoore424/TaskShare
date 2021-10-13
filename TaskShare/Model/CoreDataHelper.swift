//
//  CoreDataHelper.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/6/21.
//


import CloudKit
import CoreData
import UIKit

class CoreDataHelper {
    
    static let coreDataHelper = CoreDataHelper()
    
    let persistentContainer: NSPersistentCloudKitContainer
    
    init() {
        persistentContainer = NSPersistentCloudKitContainer(name: "TaskShare")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load with error: \(error.localizedDescription)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    //MARK: - Saving CoreData Methods
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving data to context \(error)")
        }
    }
   
    //MARK: - Group CoreData Method
    func loadGroupByDate(with request: NSFetchRequest<Group> = Group.fetchRequest(), for selectedDate: String) -> [Group] {
        let selectedDatePredicate = NSPredicate(format: "ANY task.date MATCHES %@", selectedDate)

        request.predicate = selectedDatePredicate
        
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            print("Error fetching data from context \(error)")
            return []
        }
    }
 
    //MARK: - Task CoreData Methods
    func loadTaskByDate(with request: NSFetchRequest<Task> = Task.fetchRequest(), selectedGroup: Group?, selectedDate: String) -> [Task] {
        
        let groupPredicate = NSPredicate(format: "parentGroup.title MATCHES %@", selectedGroup!.title!)
        
        let selectedDatePredicate = NSPredicate(format: "date MATCHES %@", selectedDate)

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, selectedDatePredicate])
        
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            print("Error fetching data from context \(error)")
            return []
        }
    }
    
}

extension CoreDataHelper {
    func createGroup(named title: String) {
        let group = Group(context: persistentContainer.viewContext)
        group.title = title

        do {
            try persistentContainer.viewContext.save()
        } catch {
            // failed to save, discard anything already on context
            persistentContainer.viewContext.rollback()
            print("Failed to create group: \(error)")
        }
    }
}

extension CoreDataHelper {
    func loadGroups() -> [Group] {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch groups: \(error)")
            return []
        }
    }
}

extension CoreDataHelper {
    func deleteGroup(_ group: Group) {
        persistentContainer.viewContext.delete(group)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
}

extension CoreDataHelper {
    func updateGroup() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
}

extension CoreDataHelper {
    func createTask(parentGroup: Group, name: String, note: String, date: String, completed: Bool) {
        let task = Task(context: persistentContainer.viewContext)
        task.parentGroup = parentGroup
        task.name = name
        task.note = note
        task.date = date
        task.completed = completed
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to te task: \(error)")
        }
    }
}

extension CoreDataHelper {
    func loadTasks(for selectedGroup: Group) -> [Task] {
        let groupPredicate = NSPredicate(format: "%K MATCHES %@", #keyPath(Task.parentGroup.title), selectedGroup.title!)
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = groupPredicate
        
        do {
            let result = try persistentContainer.viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Failed to fetch Tasks for \(selectedGroup); \(error)")
            return []
        }
    }
}

extension CoreDataHelper {
    func searchTasks(for selectedGroup: Group, with text: String) -> [Task] {
        let groupPredicate = NSPredicate(format: "%K MATCHES %@", #keyPath(Task.parentGroup.title), selectedGroup.title!)
        
        let inputPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Task.name), text)
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, inputPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let result = try persistentContainer.viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Failed to load Tasks for \(selectedGroup) with search paramater of \(text); \(error)")
            return []
        }
    }
}
