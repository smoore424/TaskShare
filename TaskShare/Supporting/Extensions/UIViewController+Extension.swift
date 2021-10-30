//
//  UIViewController+Extension.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/27/21.
//

import UIKit

extension UIViewController {
    
    func presentSnackOnMainThread(message: String, image: UIImage) {
        DispatchQueue.main.async {
            let vc = SnackBarVC(message: message, image: image)
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { vc.dismiss(animated: true, completion: nil) }
        }
    }
    
    
    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = TSEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
}
