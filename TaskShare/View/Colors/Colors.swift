//
//  Colors.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/29/21.
//

import UIKit

class Colors {
    
    static let shared = Colors()
    
    let defaults = UserDefaults.standard
    
    let colorOptions: [UIColor] = [.systemBlue, .systemGreen, .systemBrown, .systemIndigo, .systemOrange, .systemPink, .systemPurple, .systemRed, .systemTeal, .systemYellow]
    
    var selectedColorIndex = 8
    
    private init () {}
    
    func setSelectedColor() {
        selectedColorIndex = defaults.object(forKey: "color") as? Int ?? 8
    }
    
    
    func getCurrentColor() -> UIColor {
        return colorOptions[selectedColorIndex]
    }
    
    
    func setCellColors(cellLocation: Int, arrayCount: Int) -> UIColor {
        setSelectedColor()
        
        let cellOpacity = (CGFloat(cellLocation) / CGFloat(arrayCount)) + 0.05
        let color = colorOptions[selectedColorIndex].withAlphaComponent(cellOpacity)
        
        return color
    }
}
