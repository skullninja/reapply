//
//  LearnViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/20/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

class LearnViewController: GenericViewController, UICollectionViewDelegate {

    @IBOutlet weak var learnCollectionView: UICollectionView!
    
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
        return newsResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewsCollectionViewCell
        let news = self.newsResults[indexPath.item] as News
        cell.news =  news
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
          return .init(width: view.frame.width, height: 240)
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
