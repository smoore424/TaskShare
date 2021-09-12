//
//  TasksTableViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/17/21.
//

import CoreData
import UIKit

class TaskViewController: UITableViewController {

    var taskArray = [Task]()
    var filterDate = false
    var selectedDate = String()
    var selectedGroup: Group?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true
        searchBar.delegate = self
        moreButton.primaryAction = nil
        moreButton.menu = menuItems()
    }
    
    //MARK: - Add Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.goToTaskInfoSegue, sender: self)
    }
    
    //MARK: - Edit Table
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
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
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            taskArray[selectedIndexPath.row] = taskInfoVC.task!
        } else {
            let newIndexPath = IndexPath(row: taskArray.count, section: 0)
            taskArray.append(taskInfoVC.task!)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
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
        let image = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate)
        let info = UIImageView(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        info.image = image
        cell.accessoryView = info
        cell.tintColor = .systemGray4
        
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
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            taskArray = CoreDataHelper.loadTasks(for: selectedGroup)
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
