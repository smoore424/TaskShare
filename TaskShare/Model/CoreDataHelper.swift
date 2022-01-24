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
    
    static let shared = CoreDataHelper()
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init() {}
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "TaskShare")
        
        let privateStoreDescription = container.persistentStoreDescriptions.first!
        let storesURL = privateStoreDescription.url!.deletingLastPathComponent()
        privateStoreDescription.url = storesURL.appendingPathComponent("private.sqlite")
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        let sharedStoreURL = storesURL.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
            fatalError("Copying the private store description returned an unexpected value.")
        }
        
        sharedStoreDescription.url = sharedStoreURL
        
        let containerIdentifier = privateStoreDescription.cloudKitContainerOptions!.containerIdentifier
        let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
        sharedStoreOptions.databaseScope = .shared
        sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        
        container.persistentStoreDescriptions.append(sharedStoreDescription)
        
        container.loadPersistentStores { loadedStoreDescription, error in
            
            if let loadError = error as NSError? {
                fatalError("failed to load store \(String(describing: error?.localizedDescription))")
            } else if let cloudKitcontainerOptions = loadedStoreDescription.cloudKitContainerOptions {
                
                if .private == cloudKitcontainerOptions.databaseScope {
                    self._privatePersistentStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
                } else if .shared == cloudKitcontainerOptions.databaseScope {
                    self._sharedPersistentStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
                }
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("Fail to pin viewContext to the current generation:\(error)")
        }
        
        return container
    }()
    
    let ckContainerID = "iCloud.dev.staceymoore.taskshare"
    
    var ckContainer: CKContainer {
        CKContainer(identifier: ckContainerID)
    }
    
    private var _privatePersistentStore: NSPersistentStore?
    var privatePersistentStore: NSPersistentStore {
        return _privatePersistentStore!
    }
    
    private var _sharedPersistentStore: NSPersistentStore?
    var sharedPersistentStore: NSPersistentStore {
        return _sharedPersistentStore!
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


//MARK: Group CRUD Methods
extension CoreDataHelper {
    
    func createGroup(named title: String) {
        let group = Group(context: persistentContainer.viewContext)
        group.title = title
        
        do {
            try context.save()
        } catch {
            // failed to save, discard anything already on context
            persistentContainer.viewContext.rollback()
            print("Failed to create group: \(error)")
        }
    }
    
    
    func loadGroups() -> [Group] {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch groups: \(error)")
            return []
        }
    }
    
    
    func deleteGroup(_ group: Group) {
        context.delete(group)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
    
    
    func updateGroup() {
        do {
            try context.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
}


//MARK: Task CRUD Methods
extension CoreDataHelper {
    func createTask(parentGroup: Group, name: String, note: String, date: String, completed: Bool) {
        let task = Task(context: context)
        task.parentGroup = parentGroup
        task.name = name
        task.note = note
        task.date = date
        task.completed = completed
        
        do {
            try context.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to te task: \(error)")
        }
    }
    
    
    func loadTasks(with request: NSFetchRequest<Task> = Task.fetchRequest(), for selectedGroup: Group) -> [Task] {
        let groupPredicate = NSPredicate(format: "%K MATCHES %@", #keyPath(Task.parentGroup.title), selectedGroup.title!)
        
        request.predicate = groupPredicate
        
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            print("Failed to fetch Tasks for \(selectedGroup); \(error)")
            return []
        }
    }
    
    
    func searchTasks(for selectedGroup: Group, with text: String) -> [Task] {
        let groupPredicate = NSPredicate(format: "%K MATCHES %@", #keyPath(Task.parentGroup.title), selectedGroup.title!)
        
        let inputPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Task.name), text)
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, inputPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Failed to load Tasks for \(selectedGroup) with search paramater of \(text); \(error)")
            return []
        }
    }
}
