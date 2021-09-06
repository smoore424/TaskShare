//
//  CoreDataHelper.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/6/21.
//

import CoreData
import UIKit

struct CoreDataHelper {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }

        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext

        return context
    }()
    
    //MARK: - Shared CoreData Methods
    static func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving data to context \(error)")
        }
    }
    //MARK: - Group CoreData Methods
    static func newGroup() -> Group {
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
        return group
    }
    
    static func loadGroup(with request: NSFetchRequest<Group> = Group.fetchRequest()) -> [Group] {
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("error fetching data from context: \(error)")
            return []
        }
    }
    
    static func deleteGroup(group: Group) {
        context.delete(group)
        saveData()
    }
    
    //MARK: - Task CoreData Methods
    static func loadTasks(with request: NSFetchRequest<Task> = Task.fetchRequest(), for selectedGroup: Group?, predicate: NSPredicate? = nil) -> [Task] {
        
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
    
    
}
