//
//  Extension+UIViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/6/21.
//

import UIKit

extension UIViewController {
    
    static var textField = UITextField()
    
    private func showAlert(title: String?, message: String?, alertStyle: UIAlertController.Style, actions: [CustomAction], textField: Bool, placeHolder: String? = nil, completionHandler: @escaping ((_ action: CustomAction)->())) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { (_) in
                completionHandler(action)
            }
            alertController.addAction(alertAction)
        }
        
        if textField {
            alertController.addTextField { alertTextField in
                alertTextField.placeholder = placeHolder
                UIViewController.textField = alertTextField
            }
        }
        self.present(alertController, animated: true)
    }
    
    func addGroupAlert(completion: (() -> ())? = nil) {
        showAlert(title: "Add Group", message: "", alertStyle: .alert, actions: [.saveAction, .cancelAction], textField: true, placeHolder: "Create New Group") { (action) in
            if action.title == CustomAction.saveAction.title {
                completion!()
            }
        }
    }
    
    func editGroupAlert(completion: (() -> ())? = nil) {
        showAlert(title: "Edit Group Name", message: "", alertStyle: .alert, actions: [.saveAction, .cancelAction], textField: true, placeHolder: "Enter New Group Name") { (action) in
            if action.title == CustomAction.saveAction.title {
                completion!()
            }
        }
    }
    
    func dismissModalAlert(completion: (() -> ())? = nil) {
        showAlert(title: nil, message: nil, alertStyle: .actionSheet, actions: [.discardChangeAction, .cancelAction], textField: false) { (action) in
            if action.title == CustomAction.discardChangeAction.title {
                completion!()
            }
        }
    }
    
}

