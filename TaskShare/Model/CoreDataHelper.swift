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
    
    //MARK: - Group CoreData Methods
    func newGroup() -> Group {
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
        return group
    }
    
    func loadGroup(with request: NSFetchRequest<Group> = Group.fetchRequest()) -> [Group] {
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("error fetching data from context: \(error)")
            return []
        }
    }
    
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
    
    func deleteGroup(group: Group) {
        context.delete(group)
        saveData()
    }
    
    //MARK: - Task CoreData Methods
    func newTask() -> Task {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
        return task
    }
    
    func loadTasks(with request: NSFetchRequest<Task> = Task.fetchRequest(), for selectedGroup: Group?, predicate: NSPredicate? = nil) -> [Task] {
        
        let groupPredicate = NSPredicate(format: "parentGroup.title MATCHES %@", selectedGroup!.title!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, additionalPredicate])
        } else {
            request.predicate = groupPredicate
        }
        
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            print("Error fetching data from context \(error)")
            return []
        }
    }
    
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
