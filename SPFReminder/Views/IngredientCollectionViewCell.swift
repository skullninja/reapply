//
//  IngredientCollectionViewCell.swift
//  SPFReminder
//
//  Created by Dave Peck on 8/25/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UIKit

public class IngredientCollectionViewCell: UICollectionViewCell {
    
    private var ingredientName: String?
    
    private lazy var ingredientButton: UIButton = {
        let button = UIButton()
        self.contentView.addSubview(button)
        button.isUserInteractionEnabled = false
        button.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        return button
    }()
    
    func configure(name: String, active: Bool) {
        self.ingredientName = name
        IngredientCollectionViewCell.configureButton(self.ingredientButton, name: name)
        if active {
            self.ingredientButton.backgroundColor = UIColor.colorFromHex(0xFA3352)
            self.ingredientButton.setTitleColor(.white, for: .normal)
        } else {
            self.ingredientButton.backgroundColor = UIColor.colorFromHex(0xD8D8D8)
            self.ingredientButton.setTitleColor(.black, for: .normal)
        }
        self.ingredientButton.clipsToBounds = true
        self.ingredientButton.layer.cornerRadius = self.ingredientButton.bounds.height / 4.0
        self.contentView.sizeToFit()
        self.sizeToFit()
    }
    
    private static func configureButton(_ button: UIButton, name: String) {
        button.setTitle(name, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        var size = button.sizeThatFits(CGSize(width: 400, height: 14))
        size.width += 30
        button.frame = CGRect(origin: CGPoint.zero, size: size)
    }
    
    static func sizeFor(name: String) -> CGSize {
        let button = UIButton()
        configureButton(button, name: name)
        return button.frame.size
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.ingredientName = nil
        self.ingredientButton.setTitle(self.ingredientName, for: .normal)
    }
}
