//
//  ViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/16/21.
//

import CoreData
import UIKit

class GroupViewController: UITableViewController {
    
    var groupArray = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        groupArray = CoreDataHelper.loadGroup()
        tableView.allowsSelectionDuringEditing = true
        title = "Groups"
    }
    
    //MARK: - Add Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        addGroupAlert {
            let newGroup = CoreDataHelper.newGroup()
            newGroup.title = UIViewController.textField.text!
            self.groupArray.append(newGroup)
            CoreDataHelper.saveData()
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedGroup = groupArray[indexPath.row]
            destinationVC.title = groupArray[indexPath.row].title
            destinationVC.taskArray = CoreDataHelper.loadTasks(for: groupArray[indexPath.row])
        }
    }
    
    //MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.groupCell, for: indexPath)
        let group = groupArray[indexPath.row]
        cell.textLabel?.text = group.title
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { (contextualAction, view, actionPerformed: (Bool) -> Void) in
            CoreDataHelper.deleteGroup(group: self.groupArray[indexPath.row])
            self.groupArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            CoreDataHelper.saveData()
            tableView.reloadData()
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        groupArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        CoreDataHelper.saveData()
        tableView.reloadData()
    }

    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isEditing {
            let selectedGroup = groupArray[indexPath.row]
            editGroupAlert() {
                selectedGroup.title = UIViewController.textField.text!
                CoreDataHelper.saveData()
                self.tableView.reloadData()
            }
        } else {
            performSegue(withIdentifier: K.goToTasksSegue, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
