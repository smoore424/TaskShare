//
//  extension+UIViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/10/21.
//

import UIKit

extension UIViewController {
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    func convertStringToDate(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-d-y"
        return dateFormatter.date(from: string)
    }
}
