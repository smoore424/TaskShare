//
//  UIColor+Extension.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/5/21.
//

import UIKit

extension UIColor {
    var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        var background: CGFloat {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return 0
            } else {
                return 1
            }
        }
        
        let newRed: CGFloat = (alpha * red) + (1 - alpha)*background
        let newGreen: CGFloat = (alpha * green) + (1 - alpha)*background
        let newBlue: CGFloat = (alpha * blue) + (1 - alpha)*background
        
        return (0.2126 * newRed) + (0.7152 * newGreen) + (0.0722 * newBlue)
    }
    
    var isLight: Bool {
        return luminance >= 0.6
    }
}
