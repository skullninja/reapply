//
//  OnboardingPageContent.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 5/30/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

protocol OnboardingPageContentDelegate: AnyObject {
    func didTapNext(index: Int)
}

class OnboardingPageContent: UIViewController {
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    
    public var pageIndex = 0
    public var descriptionText: String = ""
    
    weak var delegate:OnboardingPageContentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblDescription.text = descriptionText
        
        if(pageIndex == 1){
            btnNext.setTitle("Get Started!", for: .normal)
        }
        
    }
    
    @IBAction func NextButtonTapped(_ sender: Any) {
        
        self.delegate?.didTapNext(index: self.pageIndex)
        
        
    }
    
}
                      
