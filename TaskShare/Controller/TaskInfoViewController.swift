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
    
    let coreDataHelper = CoreDataHelper.shared
    let colors = Colors.shared
    
    var selectedGroup: Group?
    var task: Task?
    
    //MARK: - Delegate
    weak var delegate: TaskInfoViewControllerDelegate?
    
    //MARK: - View
    
    //navBar
    @IBOutlet weak var taskInfoNavBar: UINavigationBar!
    
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //TODO: - write a method/model to detect if there are changes and dynamically set this with that method
        isModalInPresentation = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskNameTextField.delegate = self
        taskNameTextField.text = task?.name
        taskNameTextField.becomeFirstResponder()
        
        noteTextView.text = task?.note
        self.noteTextView.addDoneButton(target: self, selector: #selector(doneTapped(sender:)))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavControllerAppeareance()
        updateDateLabel()
    }
    
    
    @objc func doneTapped(sender: Any) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismissModalAlert {
            self.delegate?.taskInfoViewControllerDidCancel(self)
        }
    }
    
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        dateLabel.text = convertDateToString(date: datePicker.date)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let task = task {
            task.name = taskNameTextField.text
            
            task.date = convertDateToString(date: datePicker.date)
            task.note = noteTextView.text
            coreDataHelper.saveData()
        } else {
        
            coreDataHelper.createTask(
                parentGroup: selectedGroup!,
                name: taskNameTextField.text ?? "",
                note: noteTextView.text ?? "",
                date: convertDateToString(date: datePicker.date),
                completed: false)
        }
    }
}

//MARK: - Set the View
extension TaskInfoViewController {
    func setNavControllerAppeareance() {
        colors.setSelectedColor()
        taskInfoNavBar.tintColor = colors.getCurrentColor()
    }
    
    func updateDateLabel() {
     
        if let selectedDate = task?.date {
            dateLabel.text = selectedDate
            datePicker.date = convertStringToDate(string: selectedDate)!
        } else {
            dateLabel.text = convertDateToString(date: datePicker.date)
        }
    }
}

//MARK: - TableView Delegate
extension TaskInfoViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.row, indexPath.section) {
        case ((datePickerCellIndexPath.row - 1), datePickerCellIndexPath.section):
            isDatePickerShown ? (isDatePickerShown = false) : (isDatePickerShown = true)
        default:
            break
        }
        //TODO: Find a better solution to datepicker not showing/hiding correctly
        //        tableView.beginUpdates()
        //        tableView.endUpdates()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row, indexPath.section) {
        case (noteTextViewCellIndexPath.row, noteTextViewCellIndexPath.section):
            return 88
        case (datePickerCellIndexPath.row, datePickerCellIndexPath.section):
            return isDatePickerShown ? 216 : 0
        default:
            return 44
        }
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

//MARK: - TextField Delegate Methods
extension TaskInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskNameTextField.resignFirstResponder()
        return true
    }
}
