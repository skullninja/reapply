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
        guard let url = URL(string: "https://amberreyn.wixsite.com/mysite-5/sun-care-basics") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnTipsTapped(_ sender: Any) {
        guard let url = URL(string: "https://amberreyn.wixsite.com/mysite-5/sun-care-basics") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnReviewsTapped(_ sender: Any) {
        guard let url = URL(string: "https://amberreyn.wixsite.com/mysite-5/sunscreen-reviews") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnShopTapped(_ sender: Any) {
        guard let url = URL(string: "https://amberreyn.wixsite.com/mysite-5/sun-care-basics") else { return }
        UIApplication.shared.open(url)
    }
    
}
