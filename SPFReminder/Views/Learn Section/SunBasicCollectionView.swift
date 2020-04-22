//
//  SunBasicCollectionReusableView.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/21/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

class SunBasicCollectionView: UICollectionReusableView {
    
    let horizontalController = SunBasicHorizontalCollectionView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(horizontalController.view)
        horizontalController.view.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
