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
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var imgTitle: UIImageView!
    
    public var pageIndex = 0
    public var descriptionText: String = ""
    public var imageName: String = ""
    
    weak var delegate:OnboardingPageContentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblDescription.text = descriptionText
        
        let image : UIImage = UIImage(named:imageName)!
        self.imgBackground.image = image
        
        if pageIndex > 0 {
            lblWelcome.isHidden = true
            imgTitle.isHidden = true
        }else{
            lblWelcome.isHidden = false
            imgTitle.isHidden = false
        }
        
        if(pageIndex == 3){
            btnNext.setTitle("Get Started!", for: .normal)
            btnNext.isHidden = false
        }else{
          btnNext.isHidden = true
        }
        
    }
    
    @IBAction func NextButtonTapped(_ sender: Any) {
        
        self.delegate?.didTapNext(index: self.pageIndex)
        
        
    }
    
}
                      
