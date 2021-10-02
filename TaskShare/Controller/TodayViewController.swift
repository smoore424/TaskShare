//
//  TodayViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/8/21.
//

import CoreData
import UIKit

class TodayViewController: UIViewController {
    
    
    @IBOutlet weak var calendarView: UIDatePicker!
    @IBOutlet weak var todayTableView: UITableView!
    
    var colors = Colors()
    
    var groupArray = [Group]()
    var selectedDate = String()
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavControllerAppearance()
        calendarView.tintColor = colors.getCurrentColor()
        todayTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayTableView.delegate = self
        todayTableView.dataSource = self
        getTableViewData()
        todayTableView.refreshControl = refreshController
    }
    
    //MARK: - Pull to Refresh
    @objc func pullToRefresh() {
        refreshController.beginRefreshing()
        getTableViewData()
        //put in completion block of func used to call data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.todayTableView.reloadData()
            self.refreshController.endRefreshing()
        }
    }
    
    //MARK: - Date Selection
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        getTableViewData()
    }
    
    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskViewController
        if let indexPath = todayTableView.indexPathForSelectedRow {
            destinationVC.filterDate = true
            destinationVC.title = groupArray[indexPath.row].title
            destinationVC.selectedGroup = groupArray[indexPath.row]
            destinationVC.selectedDate = selectedDate
            destinationVC.taskArray = CoreDataHelper.loadTaskByDate(selectedGroup: groupArray[indexPath.row], selectedDate: selectedDate)
        }
    }
}

//MARK: - Set the View
extension TodayViewController {
    func setNavControllerAppearance() {
        colors.setSelectedColor()
        navigationController?.navigationBar.tintColor = colors.getCurrentColor()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: colors.getCurrentColor()]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        title = "Today"
    }
    
    func getTableViewData() {
        selectedDate = convertDateToString(date: calendarView.date)
        groupArray = CoreDataHelper.loadGroupByDate(for: selectedDate)
        title = selectedDate
        todayTableView.reloadData()
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
        
        let color = colors.setCellColors(cellLocation: indexPath.row, arrayCount: groupArray.count)
        cell.backgroundColor = color
        cell.textLabel?.textColor = color.cgColor.alpha > 0.56 ? .white : .black
        
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
