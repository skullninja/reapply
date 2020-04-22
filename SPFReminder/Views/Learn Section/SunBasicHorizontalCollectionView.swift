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

    var basics = [SunBasics]()
    
    let cellId = "cellId"
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
       
       
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
           
        collectionView.register(SunBasicCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
           
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        self.collectionView.backgroundColor = .white
       
        setupData()
    }
    
    func setupData(){
        let basic1 = SunBasics()
        basic1.title =  "What is SPF?"
        basic1.url  = "https://www.reapplyapp.com/post/what-is-spf"
        basic1.imageName =  "spf"
        
        let basic2 = SunBasics()
        basic2.title =  "What is UV Index?"
        basic2.url  = "https://www.reapplyapp.com/post/what-is-ultraviolet-index-uv-index"
        basic2.imageName =  "sky"
        
        let basic3 = SunBasics()
        basic3.title =  "What is UVA and UVB?"
        basic3.url  = "https://www.reapplyapp.com/post/what-is-uva-uvb-rays"
        basic3.imageName =  "spf"
        
        let basic4 = SunBasics()
        basic4.title =  "Chemical or Mineral Sunscreens?"
        basic4.url  = "https://www.reapplyapp.com/post/chemical-and-mineral-aka-physical-sunscreens"
        basic4.imageName =  "spf"
        
        self.basics.append(basic1)
        self.basics.append(basic2)
        self.basics.append(basic3)
        self.basics.append(basic4)
        
        self.collectionView.reloadData()
    }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return .init(width: view.frame.width - 80, height: view.frame.height)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return .init(top: 0, left: 16, bottom: 0, right: 0)
       }
       
       override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.basics.count
       }
       
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SunBasicCollectionViewCell
        let basic = self.basics[indexPath.item] as SunBasics
        cell.basic = basic
        return cell
    }
}
