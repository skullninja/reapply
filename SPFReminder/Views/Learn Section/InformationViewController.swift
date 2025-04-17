//   NO LONGER IN USE - REPLACED WITH LearnViewController
//  Deprecated
//  InformationViewController.swift
//  SPFReminder
//
//  Created by Dave Peck on 4/22/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit
import Firebase


//DEPRECATEDDeprecated - replaced with LearnViewController
class InformationViewController: GenericViewController {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "learn", AnalyticsParameterScreenClass: "InformationViewController"])
    }

    
    @IBAction func btnSunBasicsTapped(_ sender: Any) {
        
        Analytics.logEvent(AnalyticsEvents.suncareTapped, parameters: nil)
        
        guard let url = URL(string: APIKeys.value(for: .sunCareBasicsURL)) else { return }
        UIApplication.shared.open(url)
        
    }
    
    @IBAction func btnTipsTapped(_ sender: Any) {
        
        Analytics.logEvent(AnalyticsEvents.safetyTipsTapped, parameters: nil)
        
        let webViewController = WebViewController()
        webViewController.urlString = APIKeys.value(for: .safetyTipsURL)
        webViewController.blogPost = false
        self.present(webViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnReviewsTapped(_ sender: Any) {
        
        Analytics.logEvent(AnalyticsEvents.reviewsTapped, parameters: nil)
        
        guard let url = URL(string: APIKeys.value(for: .reviewsURL)) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnShopTapped(_ sender: Any) {
        
        Analytics.logEvent(AnalyticsEvents.shopFavesTapped, parameters: nil)
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController")
        self.storeTransitioningDelegate = StoreTransitioningDelegate(viewController: storeVC, presentingViewController: self)
        storeVC.modalPresentationStyle = .custom
        storeVC.transitioningDelegate = self.storeTransitioningDelegate
        present(storeVC, animated: true, completion: nil)
    
    }
    
}
