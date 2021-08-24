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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    @IBOutlet weak var repeatPicker: UIPickerView!
    let repeatPickerCellIndexPath = IndexPath(row: 1, section: 3)
    var isRepeatPickerShown: Bool = false {
        didSet {
            repeatPicker.isHidden = !isRepeatPickerShown
        }
    }
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
    
    @IBAction func repeatSwitchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            isRepeatPickerShown = true
        } else {
            isRepeatPickerShown = false
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newTask = Task(context: self.context)
        newTask.name = taskNameTextField.text
        newTask.parentGroup = selectedGroup
        newTask.date = datePicker.date
        newTask.note = noteTextView.text
        newTask.repeatSwtichIsOn = repeatSwitch.isOn
        newTask.repeatPickerComponent1 = ""
        task = newTask
        saveItem()
        print(newTask)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        cancel()
    }
    
    func cancel() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let discard = UIAlertAction(title: "Discard Changes", style: .destructive) { discard in
            self.delegate?.taskInfoViewControllerDidCancel(self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(discard)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
        case (noteTextViewCellIndexPath.row, noteTextViewCellIndexPath.section):
            return 88
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
        default:
            return 44
        }
    }
    //MARK: - CRUD Methods
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
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
        //TODO: Read value from picker and put into core data
        //TODO: Add feedback label in repeat picker section
        print("\(repeatPickerData[component][row])")
    }
}

//MARK: - PresentationControllerDelegate
extension TaskInfoViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancel()
    }
}
