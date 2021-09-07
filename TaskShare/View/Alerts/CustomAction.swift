//
//  CustomAction.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/6/21.
//

import UIKit

struct CustomAction {
    let title: String
    let style: UIAlertAction.Style
    
    static let saveAction = CustomAction(title: "Save", style: .default)
    static let cancelAction = CustomAction(title: "Cancel", style: .cancel)
    static let discardChangeAction = CustomAction(title: "Discard Changes", style: .destructive)
}
