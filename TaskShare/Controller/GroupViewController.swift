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

    @IBOutlet weak var editButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        groupArray = CoreDataHelper.loadGroup()
        tableView.allowsSelectionDuringEditing = true
        title = "My Groups"
    }
    
    //MARK: - Add Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        addItemAlert()
    }
    
    //MARK: - Edit Table
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedGroup = groupArray[indexPath.row]
            destinationVC.title = groupArray[indexPath.row].title
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isEditing {
            editItemAlert(selectedGroup: groupArray[indexPath.row])
        } else {
            performSegue(withIdentifier: K.goToTasksSegue, sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Alerts
    func addItemAlert() {
        let alert = UIAlertController(title: "Add Group", message: nil, preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newGroup = Group(context: CoreDataHelper.context)
            newGroup.title = textField.text!
            self.groupArray.append(newGroup)
            CoreDataHelper.saveData()
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Group"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func editItemAlert(selectedGroup: Group) {
        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Save", style: .default) { action in
            selectedGroup.title = textField.text!
            CoreDataHelper.saveData()
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter New Group Name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
