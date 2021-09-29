//
//  TasksTableViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/17/21.
//

import CoreData
import UIKit

class TaskViewController: UITableViewController {
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemRed
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    var taskArray = [Task]()
    var filterDate = false
    var selectedDate = String()
    var selectedGroup: Group?
    
    let colors = Colors()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        searchBar.delegate = self
        moreButton.primaryAction = nil
        moreButton.menu = menuItems()
        tableView.refreshControl = refreshController        
    }
    
    @objc func pullToRefresh() {
        refreshController.beginRefreshing()
        taskArray = CoreDataHelper.loadTasks(for: selectedGroup)
        

        //put in completion block of func used to call data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        }
        
    }
    
    //MARK: - Add Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.goToTaskInfoSegue, sender: self)
    }
    
    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskInfoViewController
        destinationVC.presentationController?.delegate = destinationVC
        destinationVC.delegate = self
        
        switch segue.identifier {
        case K.goToTaskInfoSegue:
            destinationVC.selectedGroup = selectedGroup
        case K.goToTaskEditSegue:
            destinationVC.task = taskArray[tableView.indexPathForSelectedRow!.row]
        default:
            break
        }
    }
    
    @IBAction func unwindToTaskVC(_ unwindSegue: UIStoryboardSegue) {
        let taskInfoVC = unwindSegue.source as! TaskInfoViewController
        
        //check to see if we are updating an existing task or adding a new task
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            taskArray[selectedIndexPath.row] = taskInfoVC.task!
        } else {
            if filterDate {
                taskArray = CoreDataHelper.loadTaskByDate(selectedGroup: selectedGroup, selectedDate: selectedDate)
            } else {
                taskArray = CoreDataHelper.loadTasks(for: selectedGroup)
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.taskCell, for: indexPath) as! TaskTableViewCell
        cell.delegate = self
        //TODO: - move to TaskTableViewCell class
        cell.tintColor = .systemGray
        
        cell.backgroundColor = colors.setCellColors(cellLocation: indexPath.row, arrayCount: taskArray.count)
        
        let task = taskArray[indexPath.row]
        cell.taskLabel.text = task.name
        cell.checkmarkButton.isSelected = task.completed
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { (contextualAction, view, actionPerformed: (Bool) -> Void) in
            self.context.delete(self.taskArray[indexPath.row])
            self.taskArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            CoreDataHelper.saveData()
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        taskArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        CoreDataHelper.saveData()
    }

    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if TaskViewController.showComplete {
            return 50
        } else {
            if taskArray[indexPath.row].completed {
                return 0
            } else {
                return 50
            }
        }
    }
    
}

//MARK: - TaskInfoViewControllerDelegate
extension TaskViewController: TaskInfoViewControllerDelegate {
    func taskInfoViewControllerDidCancel(_ taskInfoViewController: TaskInfoViewController) {
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
}

//MARK: - TaskTableViewCellDelegate
extension TaskViewController: TaskTableViewCellDelegate {
    func checkMarkToggle(sender: TaskTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            taskArray[selectedIndexPath.row].completed.toggle()
            CoreDataHelper.saveData()
            tableView.reloadData()
        }
    }
    
}

//MARK: - SearchBarDelegate
extension TaskViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        taskArray = CoreDataHelper.loadTasks(with: request, for: selectedGroup, predicate: predicate)
        //TODO: check if filterdate and add appropriate predicate
        
        tableView.reloadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            if filterDate {
                taskArray = CoreDataHelper.loadTaskByDate(selectedGroup: selectedGroup, selectedDate: selectedDate)
            } else {
                taskArray = CoreDataHelper.loadTasks(for: selectedGroup)
            }
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
