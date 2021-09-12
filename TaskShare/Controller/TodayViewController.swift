//
//  TodayViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/8/21.
//

import CoreData
import UIKit

class TodayViewController: UIViewController {
    
    var groupArray = [Group]()
    var selectedDate = String()

    @IBOutlet weak var calendarView: UIDatePicker!
    @IBOutlet weak var todayTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Today" //change to date selected on calendar
        todayTableView.delegate = self
        todayTableView.dataSource = self
        getTableViewData()
    }
    
    func getTableViewData() {
        selectedDate = convertDateToString(date: calendarView.date)
        groupArray = CoreDataHelper.loadGroupByDate(for: selectedDate)
        todayTableView.reloadData()
    }

    @IBAction func dateSelected(_ sender: UIDatePicker) {
        getTableViewData()
    }
    
    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskViewController
        if let indexPath = todayTableView.indexPathForSelectedRow {
            let today = convertDateToString(date: Date())
            print(today)
            destinationVC.title = groupArray[indexPath.row].title
            destinationVC.selectedGroup = groupArray[indexPath.row]
            destinationVC.selectedDate = selectedDate
            destinationVC.taskArray = CoreDataHelper.loadTaskByDate(selectedGroup: groupArray[indexPath.row], selectedDate: selectedDate)
        }
    }
}

//MARK: - TableView DataSource
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todayTableView.dequeueReusableCell(withIdentifier: K.todayCell, for: indexPath)
        //configure the cell
        let group = groupArray[indexPath.row]
        cell.textLabel?.text = group.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

//MARK: - TableView Delegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.goToTodayTasksSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

