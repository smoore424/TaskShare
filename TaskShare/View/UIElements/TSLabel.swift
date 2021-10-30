//
//  TSLabel.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/30/21.
//

import UIKit

class TSLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
    }
    
    
    private func configure() {
        textColor = .label
        translatesAutoresizingMaskIntoConstraints = false
    }
}