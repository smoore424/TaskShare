//
//  TaskInfoViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/17/21.
//

import CoreData
import UIKit

protocol TaskInfoViewControllerDelegate: AnyObject {
    func taskInfoViewControllerDidCancel(_ taskInfoViewController: TaskInfoViewController)
}

class TaskInfoViewController: UITableViewController {
    
    var task: Task?
    var selectedGroup: Group?

    //MARK: - Delegate
    weak var delegate: TaskInfoViewControllerDelegate?
    
    //MARK: - View
    //Task Section
    @IBOutlet weak var taskNameTextField: UITextField!
    
    //Note Section
    @IBOutlet weak var noteTextView: UITextView!
    let noteTextViewCellIndexPath = IndexPath(row: 0, section: 1)
    
    //Date section
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    let datePickerCellIndexPath = IndexPath(row: 1, section: 2)
    var isDatePickerShown: Bool = false {
        didSet {
            datePicker.isHidden = !isDatePickerShown
        }
    }
    
    //Repeat Section
    @IBOutlet weak var repeatSwitch: UISwitch!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var repeatPicker: UIPickerView!
    let repeatPickerCellIndexPath = IndexPath(row: 1, section: 3)
    var isRepeatPickerShown: Bool = false {
        didSet {
            repeatPicker.isHidden = !isRepeatPickerShown
        }
    }
    var repeatIsOn = false
    var selectedNumber = 0
    var selectedTimeFrame = 0
    
    let repeatPickerData = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"], ["Day(s)", "Week(s)", "Month(s)", "Year(s)"]]
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //TODO: - write a method/model to detect if there are changes and dynamically set this with that method
        isModalInPresentation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatPicker.dataSource = self
        repeatPicker.delegate = self
        taskNameTextField.text = task?.name
        noteTextView.text = task?.note
        setRepeatUI()
        updateDateLabel()
    }

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDateLabel()
    }
    
    func updateDateLabel() {
        if let selectedDate = task?.date {
            dateLabel.text = selectedDate
            print(selectedDate)
            datePicker.date = convertStringToDate(string: selectedDate)!
        } else {
            dateLabel.text = convertDateToString(date: datePicker.date)
        }
    }
    
    @IBAction func repeatSwitchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            repeatIsOn = true
            isRepeatPickerShown = true
            repeatLabel.text = "Repeat Every \(repeatPickerData[0][selectedNumber]) \(repeatPickerData[1][selectedTimeFrame])"
        } else {
            repeatIsOn = false
            isRepeatPickerShown = false
            repeatLabel.text = "Repeat"
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func setRepeatUI() {
        if let task = task {
            repeatIsOn = (task.repeatSwitchIsOn)
            repeatSwitch.setOn(repeatIsOn, animated: true)
            repeatSwitchDidChange(repeatSwitch)
            selectedNumber = Int(task.selectedNumber)
            selectedTimeFrame = Int(task.selectedTimeFrame)
        }
        repeatPicker.selectRow(Int(selectedNumber), inComponent: 0, animated: true)
        repeatPicker.selectRow(Int(selectedTimeFrame), inComponent: 1, animated: true)
        repeatLabel.text = "Repeat Every \(repeatPickerData[0][selectedNumber]) \(repeatPickerData[1][selectedTimeFrame])"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let task = task {
            task.name = taskNameTextField.text
            task.date = convertDateToString(date: datePicker.date)
            task.note = noteTextView.text
            task.repeatSwitchIsOn = repeatIsOn
            task.selectedNumber = Int16(selectedNumber)
            task.selectedTimeFrame = Int16(selectedTimeFrame)
            CoreDataHelper.saveData()
        } else {
            let newTask = CoreDataHelper.newTask()
            newTask.name = taskNameTextField.text
            newTask.parentGroup = selectedGroup
            newTask.date = convertDateToString(date: datePicker.date)
            newTask.note = noteTextView.text
            newTask.repeatSwitchIsOn = repeatIsOn
            newTask.selectedNumber = Int16(selectedNumber)
            newTask.selectedTimeFrame = Int16(selectedTimeFrame)
            newTask.completed = false
            task = newTask
            CoreDataHelper.saveData()
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismissModalAlert {
            self.delegate?.taskInfoViewControllerDidCancel(self)
        }
    }
    
    //MARK: - TableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.row, indexPath.section) {
        case ((datePickerCellIndexPath.row - 1), datePickerCellIndexPath.section):
            isDatePickerShown ? (isDatePickerShown = false) : (isDatePickerShown = true)
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row, indexPath.section) {
        case (noteTextViewCellIndexPath.row, noteTextViewCellIndexPath.section):
            return 88
        case (datePickerCellIndexPath.row, datePickerCellIndexPath.section):
            return isDatePickerShown ? 216 : 0
        case (repeatPickerCellIndexPath.row, repeatPickerCellIndexPath.section):
            return isRepeatPickerShown ? 216 : 0
        default:
            return 44
        }
    }
}

//MARK: - UIPickerViewDataSource
extension TaskInfoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatPickerData[component].count
    }
}

//MARK: - UIPickerViewDelegate
extension TaskInfoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatPickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNumber = pickerView.selectedRow(inComponent: 0)
        selectedTimeFrame = pickerView.selectedRow(inComponent: 1)
        repeatLabel.text = "Repeat Every \(repeatPickerData[0][selectedNumber]) \(repeatPickerData[1][selectedTimeFrame])"
    }
}

//MARK: - PresentationControllerDelegate
extension TaskInfoViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        dismissModalAlert {
            self.delegate?.taskInfoViewControllerDidCancel(self)
        }
    }
}
