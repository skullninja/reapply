//
//  QuizViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 9/30/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialContainerScheme


class QuizViewController: UIViewController{
     
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnOne: MDCButton!
    @IBOutlet weak var btnTwo: MDCButton!
    @IBOutlet weak var btnThree: MDCButton!
    @IBOutlet weak var btnFour: MDCButton!
    
    private lazy var questions: NSArray = {
        if let path = Bundle.main.path(forResource: "quiz", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            return jsonResult as? NSArray ?? NSArray()
        }
        return NSArray()
    }()
    
    let tagsArray: Array<String> = []
    
    override func viewDidLoad() {
           
        super.viewDidLoad()

        let orangeFillColor = UIColor(red: 245/255, green: 114/255, blue: 13/255, alpha: 1)
        let grayTextColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
        let whiteColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        
        //TO DO: set using json file
        self.lblQuestion.text = "Who do you want to protect?"
        self.btnOne.setTitle("Whole Family", for: .normal)
        self.btnTwo.setTitle("Women", for: .normal)
        self.btnThree.setTitle("Men", for: .normal)
        self.btnFour.setTitle("With Makeup", for: .normal)
        
        self.btnOne.titleLabel?.textAlignment = NSTextAlignment.center
        self.btnTwo.titleLabel?.textAlignment = NSTextAlignment.center
        self.btnThree.titleLabel?.textAlignment = NSTextAlignment.center
        self.btnFour.titleLabel?.textAlignment = NSTextAlignment.center
        
        self.btnOne.layer.cornerRadius = 0.5 * btnOne.bounds.size.width
        self.btnTwo.layer.cornerRadius = 0.5 * btnOne.bounds.size.width
        self.btnThree.layer.cornerRadius = 0.5 * btnOne.bounds.size.width
        self.btnFour.layer.cornerRadius = 0.5 * btnOne.bounds.size.width
        
        self.btnOne.setTitleColor(grayTextColor, for: .normal)
        self.btnOne.setBackgroundColor(whiteColor, for: .normal)
        
        self.btnOne.setBackgroundColor(orangeFillColor, for: .selected)
        self.btnTwo.setBackgroundColor(orangeFillColor, for: .selected)
        self.btnThree.setBackgroundColor(orangeFillColor, for: .selected)
        self.btnFour.setBackgroundColor(orangeFillColor, for: .selected)
        
        
    }
    
    @IBAction func answerTapped(sender: UIButton){
        
        switch sender.tag {
               case 1:
                self.btnOne.isSelected = true
               case 2:
                self.btnTwo.isSelected = true
               case 3:
                self.btnThree.isSelected = true
               default:
                self.btnFour.isSelected = true
           }
        
    }
    
    @IBAction func closeTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
