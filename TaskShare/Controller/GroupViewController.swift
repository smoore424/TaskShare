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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        title = "My Groups"
    }
    
    //MARK: - Add Item
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Group", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newGroup = Group(context: self.context)
            newGroup.title = textField.text!
            self.groupArray.append(newGroup)
            self.saveData()
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
    
    //MARK: - Data Manipulation
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving data to context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Group> = Group.fetchRequest()) {
        do {
            groupArray = try context.fetch(request)
        } catch {
            print("error fetching data from context \(error)")
        }
        tableView.reloadData()
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

    //MARK: - TableView Delegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TODO: - Prepare for segue
        //let destinationVC = segue.destination as! TasksViewController
        
        //if let indexPath = tableView.indexPathForSelectedRow { destinationVC.selectedGroup = groupArray[indexPath.row }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: - Segue to tasksTableViewController
        //perform segue with identifier
    }
}



