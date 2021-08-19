//
//  TaskInfoViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/17/21.
//
import CoreData
import UIKit

class TaskInfoViewController: UITableViewController {
    
    var task: Task?
    var selectedGroup: Group?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Task & Note Section
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskNoteTextView: UITextView!
    
    //Date section
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    let datePickerCellIndexPath = IndexPath(row: 1, section: 1)
    var isDatePickerShown: Bool = false {
        didSet {
            datePicker.isHidden = !isDatePickerShown
        }
    }
    
    //Repeat Section
    @IBOutlet weak var repeatSwitch: UISwitch!
    @IBOutlet weak var repeatPicker: UIPickerView!
    let repeatPickerCellIndexPath = IndexPath(row: 1, section: 2)
    var isRepeatPickerShown: Bool = false {
        didSet {
            repeatPicker.isHidden = !isRepeatPickerShown
        }
    }
    
    //Reminder Section
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var reminderPicker: UIDatePicker!
    let reminderPickerCellIndexPath = IndexPath(row: 1, section: 3)
    var isReminderPickerShown: Bool = false {
        didSet {
            reminderPicker.isHidden = !isReminderPickerShown
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDateLabel()
    }

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDateLabel()
    }
    
    func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func repeatSwitched(_ sender: UISwitch) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                let newTask = Task(context: self.context)
                newTask.name = taskNameTextField.text
                newTask.parentGroup = selectedGroup
                newTask.date = datePicker.date
                task = newTask
                saveItem()
                print(newTask)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        //write function that will present alert if cancel is tapped or if user swipes down from top
    }
    
    //MARK: - TableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.row, indexPath.section) {
        case ((datePickerCellIndexPath.row - 1), datePickerCellIndexPath.section):
            if isDatePickerShown {
                isDatePickerShown = false
            } else {
                isDatePickerShown = true
            }
        default:
            break
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row, indexPath.section) {
        case (datePickerCellIndexPath.row, datePickerCellIndexPath.section):
            if isDatePickerShown {
                return 216
            } else {
                return 0
            }
        case (repeatPickerCellIndexPath.row, repeatPickerCellIndexPath.section):
            if isRepeatPickerShown {
                return 216
            } else {
                return 0
            }
        case (reminderPickerCellIndexPath.row, reminderPickerCellIndexPath.section):
            if isReminderPickerShown {
                return 216
            } else {
                return 0
            }
        default:
            return 44
        }
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
}
