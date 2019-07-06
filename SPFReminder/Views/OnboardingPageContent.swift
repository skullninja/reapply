//
//  OnboardingPageContent.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 5/30/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

class OnboardingPageContent: UIViewController {
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgTitle: UIImageView!
    @IBOutlet weak var imgFrame: UIImageView!
    
    public var pageIndex = 0
    public var descriptionText: String = ""
    public var imageName: String = ""
    public var titleText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblDescription.text = descriptionText
        self.lblTitle.text = titleText
        
        let image : UIImage = UIImage(named:imageName)!
        self.imgBackground.image = image
        
        if pageIndex > 0 {
            lblWelcome.isHidden = true
            imgTitle.isHidden = true
            lblTitle.isHidden = false
            imgFrame.isHidden = false
            imgBackground.isHidden = false
        }else{
            lblWelcome.isHidden = false
            imgTitle.isHidden = false
            lblTitle.isHidden = true
            imgFrame.isHidden = true
            imgBackground.isHidden = true
        }
        
    }
    
}
                      
