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
    
    fileprivate var newsResults = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.learnCollectionView.delegate = self
        self.learnCollectionView.dataSource = self
        
        self.learnCollectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    
       self.learnCollectionView.register(SunBasicCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchData()
    }
    
    func fetchData() {
           
           NewsService.shared.fetchNews{ (news, error) in
               if let err = error {
                   print("Failed to fetch launches:", err)
                   //TO DO: display a nice error
                   return
               }
               self.newsResults = news!
               self.learnCollectionView.reloadData()
           }
    }
    
}

extension LearnViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newsResults.count == 0{
            return 8
        }
        return newsResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewsCollectionViewCell
        
        if newsResults.count > 0 {
            let news = self.newsResults[indexPath.item] as News
            cell.news =  news
            
            cell.sourceLabel.backgroundColor = .clear
            cell.titleLabel.backgroundColor = .clear
        }
        else{
            cell.sourceLabel.text = String(repeating: " ", count: 24)
            cell.titleLabel.text = String(repeating: " ", count: 24 * 3)
            
            cell.sourceLabel.backgroundColor = UIColor.colorFromHex(0xEBEBEB)
            cell.titleLabel.backgroundColor = UIColor.colorFromHex(0xEBEBEB)
        }
       
        cell.shimmer(containerView: cell.imageView, synchronizer: shimmerSynchronizer)
        //cell.shimmer(containerView: cell.titleLabel, synchronizer: shimmerSynchronizer)
        //cell.shimmer(containerView: cell.sourceLabel, synchronizer: shimmerSynchronizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let news = self.newsResults[indexPath.item] as News
        
        if let url = news.url {
            let webViewController = WebViewController()
            webViewController.urlString = url
            webViewController.blogPost = false
            self.present(webViewController, animated: true, completion: nil)
        }
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
        return .init(width: view.frame.width, height: 250)
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


