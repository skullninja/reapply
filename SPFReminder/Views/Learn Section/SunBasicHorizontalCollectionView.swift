//
//  SunBasicHorizontalCollectionView.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/21/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

class SunBasicHorizontalCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var basics = [SunBasics]()
    
    let cellId = "cellId"
    
    let backgroundColor = UIColor(red: 249/255, green: 245/255, blue: 240/255, alpha: 1)
    
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
        
        self.collectionView.backgroundColor = backgroundColor
        self.collectionView.showsHorizontalScrollIndicator = false
       
        setupData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 210, height: view.frame.height)
    }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 10, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let basic = self.basics[indexPath.item] as SunBasics
        
        if let url = basic.url {
            let webViewController = WebViewController()
            webViewController.urlString = url
            webViewController.blogPost = false
            self.present(webViewController, animated: true, completion: nil)
        }
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
        basic3.title =  "Chemical or Mineral?"
        basic3.url  = "https://www.reapplyapp.com/post/chemical-and-mineral-aka-physical-sunscreens"
        basic3.imageName =  "sunscreenlady"
        
        let basic4 = SunBasics()
        basic4.title =  "What is UVA UVB?"
        basic4.url  = "https://www.reapplyapp.com/post/what-is-uva-uvb-rays"
        basic4.imageName =  "uvauvb"
           
          
           
           self.basics.append(basic1)
           self.basics.append(basic2)
           self.basics.append(basic3)
           self.basics.append(basic4)
           
           self.collectionView.reloadData()
       }
}
