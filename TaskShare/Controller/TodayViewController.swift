//
//  TodayViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/8/21.
//

import UIKit

class TodayViewController: UIViewController {
    
    var groupArray = [Group]()

    @IBOutlet weak var calendarView: UIView!
    
    @IBOutlet weak var todayTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //set groupArray through CoreDataHelper with predicate that looks for tasks in the group with today's date
        title = "Today" //change to date selected on calendar
        todayTableView.delegate = self
        todayTableView.dataSource = self
    }

    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue to taskInfoVC showing only selected dates tasks
    }
}

//MARK: - TableView DataSource
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todayTableView.dequeueReusableCell(withIdentifier: K.todayCell, for: indexPath)
        //configure the cell
        cell.textLabel?.text = "Hello World"
        return cell
    }
}

//MARK: - TableView Delegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "", sender: self)
    }
}

