//
//  Colors.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/29/21.
//

import UIKit

struct Colors {
    func setCellColors(cellLocation: Int, arrayCount: Int) -> UIColor {
        
        let systemTeal = UIColor.systemTeal
        
        let cellOpacity = (CGFloat(cellLocation) / CGFloat(arrayCount))

//        let color = UIColor(red: 48/255, green: 176/255, blue: 199/255, alpha: cellOpacity)
        let color = systemTeal.withAlphaComponent(cellOpacity)
        return color
    }
}
