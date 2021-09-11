//
//  TodayViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/8/21.
//

import UIKit

class TodayViewController: UIViewController {
    
    var groupArray = [Group]()
    var dateArray = [Group]()

    
    @IBOutlet weak var calendarView: UIView!
    
    @IBOutlet weak var todayTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //set groupArray through CoreDataHelper with predicate that looks for tasks in the group with today's date
        title = "Today" //change to date selected on calendar
        todayTableView.delegate = self
        todayTableView.dataSource = self
        //TODO: Create var that gets date formated as a string
        let selectedDate = convertDateToString(date: Date())
        groupArray = CoreDataHelper.loadGroupByDate(for: selectedDate)
    }

    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue to taskInfoVC showing only selected dates tasks
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
        //current gets all the tasks for that group, need to only pull out the ones with the correct date
        cell.detailTextLabel?.text = String(group.task!.count)
        return cell
    }
}

//MARK: - TableView Delegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "", sender: self)
    }
}

