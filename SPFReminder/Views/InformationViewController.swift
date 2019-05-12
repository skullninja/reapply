//
//  InformationViewController.swift
//  SPFReminder
//
//  Created by Dave Peck on 4/22/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    
    @IBOutlet weak var btnSunBasics: UIButton!
    @IBOutlet weak var btnTips: UIButton!
    @IBOutlet weak var btnReviews: UIButton!
    @IBOutlet weak var btnShop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSunBasics.layer.cornerRadius = 6
        btnTips.layer.cornerRadius = 6
        btnReviews.layer.cornerRadius = 6
        btnShop.layer.cornerRadius = 6
    }
    
    @IBAction func btnSunBasicsTapped(_ sender: Any) {
        guard let url = URL(string: "https://www.reapplyapp.com/sun-care-basics") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnTipsTapped(_ sender: Any) {
        guard let url = URL(string: "https://www.reapplyapp.com/sun-safety-tips-1") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnReviewsTapped(_ sender: Any) {
        guard let url = URL(string: "https://www.reapplyapp.com/sunscreen-reviews") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnShopTapped(_ sender: Any) {
        guard let url = URL(string: "https://www.reapplyapp.com/shop") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func sunscreenAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController")
        present(storeVC, animated: true, completion: nil)
    }
    
}
