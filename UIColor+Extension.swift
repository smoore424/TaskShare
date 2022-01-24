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
        
        var backgroundColor: CGFloat {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return 0
            } else {
                return 1
            }
        }
        
        
        func getRGBOfAlpha(for value: CGFloat) -> CGFloat {
            return (alpha * value) + (1 - alpha) * backgroundColor
        }
        
        
        let newRed: CGFloat = getRGBOfAlpha(for: red)
        let newGreen: CGFloat = getRGBOfAlpha(for: green)
        let newBlue: CGFloat = getRGBOfAlpha(for: blue)
        
        return (0.2126 * newRed) + (0.7152 * newGreen) + (0.0722 * newBlue)
    }
    
    
    var isLight: Bool {
        return luminance >= 0.6
    }
}
