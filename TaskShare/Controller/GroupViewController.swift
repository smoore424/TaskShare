//
//  ViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/16/21.
//

import CoreData
import UIKit

class GroupViewController: UITableViewController {
    
    let coreDataHelper = CoreDataHelper.shared
    
    let colors = Colors.shared
    
    var groupArray = [Group]()
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
        tableView.refreshControl = refreshController
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavControllerAppearance()
        groupArray = coreDataHelper.loadGroups()
    }
    
    
//    func loadData() {
//        groupArray = coreDataHelper.loadGroups()
//        if groupArray.isEmpty {
//            showEmptyStateView(with: "Tap + to add a new list.", in: self.view)
//        } else {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.view.bringSubviewToFront(self.tableView)
//            }
//        }
//    }
    
    //MARK: - Pull to Refresh
    @objc func pullToRefresh() {
        refreshController.beginRefreshing()
        groupArray = coreDataHelper.loadGroups()
        //put in completion block of func used to call data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        }
    }
    
    
    //MARK: - Add Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        addGroupAlert {
            self.coreDataHelper.createGroup(named: UIViewController.textField.text!)
            self.groupArray = self.coreDataHelper.loadGroups()
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedGroup = groupArray[indexPath.row]
            destinationVC.title = groupArray[indexPath.row].title
            destinationVC.taskArray = coreDataHelper.loadTasks(for: groupArray[indexPath.row])
        }
    }
}


//MARK: - Setting the View
extension GroupViewController {
    func setNavControllerAppearance() {
        colors.setSelectedColor()
        navigationController?.navigationBar.tintColor = colors.getCurrentColor()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: colors.getCurrentColor()]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        title = "Lists"
        tableView.reloadData()
    }
}


//MARK: - TableView DataSource
extension GroupViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.groupCell, for: indexPath)
        let group = groupArray[indexPath.row]
        cell.textLabel?.text = group.title
        
        let color = colors.setCellColors(cellLocation: indexPath.row, arrayCount: groupArray.count)
        cell.backgroundColor = color
        cell.textLabel?.textColor = cell.backgroundColor!.isLight ? .black : .white
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (contextualAction, view, actionPerformed: (Bool) -> Void) in
            guard let self = self else { return }
            //while we still have the index of the object delete from context
            self.coreDataHelper.deleteGroup(self.groupArray[indexPath.row])
            //remove the item from the group array
            self.groupArray.remove(at: indexPath.row)
            //delete the row for tableview
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.coreDataHelper.saveData()
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
        self.coreDataHelper.updateGroup()
        tableView.reloadData()
    }
}

//MARK: - TableView Delegate
extension GroupViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isEditing {
            let selectedGroup = groupArray[indexPath.row]
            editGroupAlert() {
                selectedGroup.title = UIViewController.textField.text!
                self.coreDataHelper.saveData()
                self.tableView.reloadData()
            }
        } else {
            performSegue(withIdentifier: K.goToTasksSegue, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//TODO: need fetch results controller, see link Frank sent
//extension GroupViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//
//        groupArray = coreDataHelper.loadGroups()
//    }
//}
