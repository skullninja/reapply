//
//  LearnViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/20/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit
import FluentUI

class LearnViewController: GenericViewController, UICollectionViewDelegate {

    @IBOutlet weak var learnCollectionView: UICollectionView!
    
    let shimmerSynchronizer = AnimationSynchronizer()
    
    fileprivate let cellId = "newsCell"
    fileprivate let headerId = "headerId"
    
    fileprivate let tips = SunSafetyTips().tips
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.learnCollectionView.delegate = self
        self.learnCollectionView.dataSource = self
        
        self.learnCollectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    
       self.learnCollectionView.register(SunBasicCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
}

extension LearnViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewsCollectionViewCell
        
        let tip = self.tips[indexPath.item] as SunTip
        
        let news = News()
        news.title = tip.text
        news.imageUrl = tip.icon
        news.source = "Tip #" + (indexPath.row+1).description
                
        cell.news = news
        
        cell.sourceLabel.backgroundColor = .clear
        cell.titleLabel.backgroundColor = .clear
       
        cell.shimmer(containerView: cell.imageView, synchronizer: shimmerSynchronizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
          return .init(width: view.frame.width, height: 160)
      }

}

// MARK: UICollectionViewDelegateFlowLayout

extension LearnViewController:  UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 25, left: 15, bottom: 15, right: 15)
    }
    
}


extension NewsCollectionViewCell {

    /// Start or reset the shimmer
    func shimmer(containerView: UIView, synchronizer: AnimationSynchronizerProtocol) {
        guard !self.isLoaded else {
            return
        }
        // because the cells have different layouts in this example, remove and re-add the shimmers
        for view in containerView.subviews {
            if let sv = view as? ShimmerView {
                sv.removeFromSuperview()
            }
        }
        
        let shimmerView = ShimmerView(containerView: containerView,
                                      animationSynchronizer: synchronizer)
        containerView.addSubview(shimmerView)
        shimmerView.frame = containerView.bounds
        shimmerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shimmerView.backgroundColor = UIColor.colorFromHex(0xEBEBEB)
    }
}

