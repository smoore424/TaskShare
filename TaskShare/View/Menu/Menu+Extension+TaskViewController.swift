//
//  Menu+Extension+UIViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/7/21.
//

import CoreData
import UIKit

extension TaskViewController {
    static var showComplete: Bool = false
    
    func menuItems() -> UIMenu {
        
        let ascendingSort = UIAction(title: "Ascending", image: UIImage(systemName: "arrow.up")) { action in
            self.sortBy(ascending: true)
        }
        
        let descendingSort = UIAction(title: "Descending", image: UIImage(systemName: "arrow.down")) { action in
            self.sortBy(ascending: false)
        }
        
        let sortBy = UIMenu(title: "Sort By", image: UIImage(systemName: "arrow.up.arrow.down"), children: [ascendingSort, descendingSort])
        
        let showOrHideComplete = UIAction(title: "Show/Hide Complete", image: UIImage(systemName: "eye.slash")) { action in
            TaskViewController.showComplete.toggle()
            self.showOrHideComplete(show: TaskViewController.showComplete)
            self.tableView.reloadData()
        }
        
        let addMenuItems = UIMenu(title: "", options: .displayInline, children: [sortBy, showOrHideComplete])
        
        return addMenuItems
    }
    
    func showOrHideComplete(show: Bool, request: NSFetchRequest<Task> = Task.fetchRequest()) {
        if show {
            let show = NSSortDescriptor(key: "completed", ascending: true)
            request.sortDescriptors = [show]
            if filterDate {
                taskArray = CoreDataHelper.loadTaskByDate(with: request, selectedGroup: selectedGroup, selectedDate: selectedDate)
            } else {
                taskArray = CoreDataHelper.loadTasks(with: request, for: selectedGroup)
            }
        }
    }
    
    func sortBy(ascending: Bool, request: NSFetchRequest<Task> = Task.fetchRequest()) {
        let sort = NSSortDescriptor(key: "name", ascending: ascending, selector: #selector(NSString.localizedStandardCompare))
        request.sortDescriptors = [sort]
        
        if filterDate {
            taskArray = CoreDataHelper.loadTaskByDate(with: request, selectedGroup: selectedGroup, selectedDate: selectedDate)
        } else {
            taskArray = CoreDataHelper.loadTasks(with: request, for: selectedGroup)
        }

        tableView.reloadData()
    }
}
