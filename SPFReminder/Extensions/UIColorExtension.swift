//
//  UIColorExtension.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func colorFromHex(_ hex: Int) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
