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
    var selectedGroup: Group? {
        didSet {
            loadData()
        }
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskInfoViewController
        destinationVC.presentationController?.delegate = destinationVC
        destinationVC.delegate = self
        
        switch segue.identifier {
        case K.goToTaskInfoSegue:
            destinationVC.selectedGroup = selectedGroup!
        case K.goToTaskEditSegue:
            destinationVC.task = taskArray[tableView.indexPathForSelectedRow!.row]
        default:
            break
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.goToTaskInfoSegue, sender: self)
    }
    
    @IBAction func unwindToTaskVC(_ unwindSegue: UIStoryboardSegue) {
        let taskInfoVC = unwindSegue.source as! TaskInfoViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            taskArray[selectedIndexPath.row] = taskInfoVC.task!
        } else {
            let newIndexPath = IndexPath(row: taskArray.count, section: 0)
            taskArray.append(taskInfoVC.task!)
            print("\(taskArray)")
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

    //MARK: - TableView Delegate
    
    //MARK: - CRUD Methods
    //TODO: move Crud methods to their own class?
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Task> = Task.fetchRequest(), predicate: NSPredicate? = nil) {
        let groupPredicate = NSPredicate(format: "parentGroup.title MATCHES %@", selectedGroup!.title!)
        request.predicate = groupPredicate
        do {
            taskArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

extension TaskViewController: TaskInfoViewControllerDelegate {
    func taskInfoViewControllerDidCancel(_ taskInfoViewController: TaskInfoViewController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - TaskTableViewCellDelegate
extension TaskViewController: TaskTableViewCellDelegate {
    func checkMarkToggle(sender: TaskTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            taskArray[selectedIndexPath.row].completed.toggle()
            saveData()
//            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
    }
    
    
}
