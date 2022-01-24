//
//  TSContainerView.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/27/21.
//

import UIKit

class TSContainerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
        backgroundColor = .secondarySystemBackground

        translatesAutoresizingMaskIntoConstraints = false
    }
}
