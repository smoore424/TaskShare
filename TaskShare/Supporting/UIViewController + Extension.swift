//
//  UIViewController + Extension.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/13/21.
//

import UIKit

extension UIViewController {
    
    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = EmptyState(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
}
