//
//  TasksTableViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/17/21.
//

import CloudKit
import CoreData
import UIKit

class TaskViewController: UITableViewController {
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let coreDataHelper = CoreDataHelper.shared
    let colors = Colors.shared
   
    var taskArray = [Task]()
    
    var filterDate = false
    var selectedDate = String()
    var selectedGroup: Group?
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        moreButton.primaryAction = nil
        moreButton.menu = menuItems()
        tableView.refreshControl = refreshController
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavControllerAppearence()
        tableView.reloadData()
    }
    
    
    //MARK: - Pull to Refresh
    @objc func pullToRefresh() {
        refreshController.beginRefreshing()
        taskArray = coreDataHelper.loadTasks(for: selectedGroup!)
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
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let tableViewEditingMode = tableView.isEditing
        
        tableView.setEditing(!tableViewEditingMode, animated: true)
        
        if tableViewEditingMode {
            editButton.title = "Edit"
        } else {
            editButton.title = "Done"
        }
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
                taskArray = coreDataHelper.loadTaskByDate(selectedGroup: selectedGroup, selectedDate: selectedDate)
            } else {
                taskArray = coreDataHelper.loadTasks(for: selectedGroup!)
            }
        }
        tableView.reloadData()
    }    
}


//MARK: - Set the View
extension TaskViewController {
    func setNavControllerAppearence() {
        colors.setSelectedColor()
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: colors.getCurrentColor()]
        navigationController?.navigationBar.tintColor = colors.getCurrentColor()
    }
}


// MARK: - TableView DataSource
extension TaskViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.taskCell, for: indexPath) as! TaskTableViewCell
        cell.delegate = self
        //TODO: - move to TaskTableViewCell class
        cell.tintColor = .systemGray

        let task = taskArray[indexPath.row]
        cell.taskLabel.text = task.name
        cell.checkmarkButton.isSelected = task.completed
        
        let color = colors.setCellColors(cellLocation: indexPath.row, arrayCount: taskArray.count)
        cell.backgroundColor = color
        cell.textLabel?.textColor = cell.backgroundColor!.isLight ? .black : .white
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { (contextualAction, view, actionPerformed: (Bool) -> Void) in
            let context = self.coreDataHelper.context
            context.delete(self.taskArray[indexPath.row])
            self.taskArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.coreDataHelper.saveData()
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        taskArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        coreDataHelper.saveData()
    }
}


//MARK: - TableView Delegate
extension TaskViewController {
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


//MARK: - SearchBarDelegate
extension TaskViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        taskArray = coreDataHelper.searchTasks(for: selectedGroup!, with: searchBar.text!)
        //TODO: check if filterdate and add appropriate predicate
        
        tableView.reloadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            if filterDate {
                taskArray = coreDataHelper.loadTaskByDate(selectedGroup: selectedGroup, selectedDate: selectedDate)
            } else {
                taskArray = coreDataHelper.loadTasks(for: selectedGroup!)
            }
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


//MARK: - TaskInfoViewController Delegate
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
            coreDataHelper.saveData()
            tableView.reloadData()
        }
    }
}
