//
//  TaskTableViewCell.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/24/21.
//

import UIKit

protocol TaskTableViewCellDelegate: AnyObject {
    func checkMarkToggle(sender: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {
    
    weak var delegate: TaskTableViewCellDelegate?

    @IBOutlet weak var checkmarkButton: UIButton!
    
    @IBOutlet weak var taskLabel: UILabel!
    
    @IBAction func checkmarkToggle(_ sender: UIButton) {
        delegate?.checkMarkToggle(sender: self)
    }
}
