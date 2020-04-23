//
//  SunBasicCollectionViewCell.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/21/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

class SunBasicCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel(text: "What is UV Index?", font: .systemFont(ofSize: 17, weight: .light))
       
    let grayTextColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    
    let imageView = UIImageView(cornerRadius: 8)
    
    var basic: SunBasics! {
           
        didSet {
            
            if let title = basic.title{
                titleLabel.text = title
            }
            
            if let imageName = basic.imageName{
                imageView.image = UIImage(named: imageName)
            }
       }
    }
       
    override init(frame: CGRect) {
        super.init(frame: frame)
           
        titleLabel.textColor = grayTextColor
        titleLabel.numberOfLines = 2
           
           let stackView = VerticalStackView(arrangedSubviews: [
               titleLabel,
               imageView
               ], spacing: 12)
           addSubview(stackView)
           stackView.fillSuperview(padding: .init(top: 16, left: 0, bottom: 0, right: 0))
       }
       
       required init?(coder aDecoder: NSCoder) {
           fatalError()
       }
}
