//
//  MoreProductInfoViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 6/23/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

class MoreProductInfoViewController: UIViewController{
    
    @IBOutlet weak var lblbrand: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductDescription: UILabel!
    
    public var descriptionText: String = ""
    public var brandText: String = ""
    public var nameText: String = ""
    
    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblbrand.text = brandText
        self.lblProductName.text = nameText
        self.lblProductDescription.text = descriptionText
        
    }
    
    override func viewDidLayoutSubviews() {
        lblProductDescription.sizeToFit()
    }
    
}
