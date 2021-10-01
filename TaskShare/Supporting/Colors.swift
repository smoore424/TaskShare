//
//  Colors.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/29/21.
//

import UIKit

struct Colors {
    
    let defaults = UserDefaults.standard
    let colorOptions: [UIColor] = [.systemBlue, .systemGreen, .systemBrown, .systemIndigo, .systemOrange, .systemPink, .systemPurple, .systemRed, .systemTeal, .systemYellow]
    
    var selectedColorIndex = 8
    
    mutating func setSelectedColor() {
        selectedColorIndex = defaults.object(forKey: "color") as? Int ?? 8
        print("\(String(describing: defaults.object(forKey: "color")))")
    }
    
    mutating func getCurrentColor() -> UIColor {
//        setSelectedColor()
        return colorOptions[selectedColorIndex]
    }
    
    mutating func setCellColors(cellLocation: Int, arrayCount: Int) -> UIColor {
        setSelectedColor()
//        let systemTeal = UIColor.systemTeal
        
        let cellOpacity = (CGFloat(cellLocation) / CGFloat(arrayCount))

//        let color = UIColor(red: 48/255, green: 176/255, blue: 199/255, alpha: cellOpacity)
        let color = colorOptions[selectedColorIndex].withAlphaComponent(cellOpacity)
        return color
    }
}
