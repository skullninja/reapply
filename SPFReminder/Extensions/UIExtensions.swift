//
//  UIExtensions.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/20/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
    }
}

extension UIImageView {
    convenience init(cornerRadius: CGFloat) {
        self.init(image: nil)
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
}

extension UIView {
    func fillSuperview(padding: UIEdgeInsets = .zero) {
           translatesAutoresizingMaskIntoConstraints = false
           if let superviewTopAnchor = superview?.topAnchor {
               topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
           }
           
           if let superviewBottomAnchor = superview?.bottomAnchor {
               bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
           }
           
           if let superviewLeadingAnchor = superview?.leadingAnchor {
               leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
           }
           
           if let superviewTrailingAnchor = superview?.trailingAnchor {
               trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
           }
       }
}

