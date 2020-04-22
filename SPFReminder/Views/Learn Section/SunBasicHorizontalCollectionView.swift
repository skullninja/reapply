//
//  SunBasicHorizontalCollectionView.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/21/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "horizontalCell"

class SunBasicHorizontalCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
       
       
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
           super.viewDidLoad()
           collectionView.backgroundColor = .white
           
           collectionView.register(SunBasicCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
           
           if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
               layout.scrollDirection = .horizontal
           }
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return .init(width: view.frame.width - 110, height: view.frame.height)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return .init(top: 0, left: 16, bottom: 0, right: 0)
       }
       
       override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 3
       }
       
       override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
           return cell
       }
}
