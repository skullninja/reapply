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
    
    var questionCounter = 0
    
    private lazy var questions: NSArray = {
        if let path = Bundle.main.path(forResource: "quiz", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            return jsonResult as? NSArray ?? NSArray()
        }
        return NSArray()
    }()
    
    var tagsArray: Array<String> = []
    
    override func viewDidLoad() {
           
        super.viewDidLoad()

        let orangeFillColor = UIColor(red: 245/255, green: 114/255, blue: 13/255, alpha: 1)
        let grayTextColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
        let whiteColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        
        //Get the first question
        let firstQuestion = self.questions[0]
        let questionDict = firstQuestion as! Dictionary<String, AnyObject>
        let questionOne = questionDict["question"] as! String
        
        self.lblQuestion.text = questionOne
        
        let answerOptions = questionDict["answers"] as! Array<String>
        
        self.btnOne.setTitle(answerOptions[0], for: .normal)
        self.btnTwo.setTitle(answerOptions[1], for: .normal)
        self.btnThree.setTitle(answerOptions[2], for: .normal)
        self.btnFour.isHidden = true
        
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
        
        if (questionCounter == 3){ return }
        
        var buttonTitle = sender.title(for: .normal)
        buttonTitle = buttonTitle?.trimmingCharacters(in: .whitespaces)
        
        let answerTag = buttonTitle!.lowercased()
        self.tagsArray.append(answerTag)
        
        switch sender.tag {
               case 1:
                self.btnOne.isSelected = true
                
                self.btnTwo.isEnabled = false
                self.btnThree.isEnabled = false
                self.btnFour.isEnabled = false
                
               case 2:
                self.btnTwo.isSelected = true
            
                self.btnOne.isEnabled = false
                self.btnThree.isEnabled = false
                self.btnFour.isEnabled = false
            
               case 3:
                self.btnThree.isSelected = true
                
                self.btnOne.isEnabled = false
                self.btnTwo.isEnabled = false
                self.btnFour.isEnabled = false
            
               default:
                self.btnFour.isSelected = true
            
                self.btnOne.isEnabled = false
                self.btnTwo.isEnabled = false
                self.btnThree.isEnabled = false
           }
    
        questionCounter = questionCounter + 1
        self.resetButtons()
        self.btnFour.isHidden = true
        
        let question = self.questions[questionCounter]
        let questionDict = question as! Dictionary<String, AnyObject>
               
        let questionText = questionDict["question"] as! String
        self.lblQuestion.text = questionText
        
        let answerOptions = questionDict["answers"] as! Array<String>
               
        self.btnOne.setTitle(answerOptions[0], for: .normal)
        self.btnTwo.setTitle(answerOptions[1], for: .normal)
        self.btnThree.setTitle(answerOptions[2], for: .normal)
        
        if (questionCounter == 1 && answerTag == "women"){
            self.btnFour.isHidden = false
            self.btnFour.setTitle(answerOptions[3], for: .normal)
        }
        
        //TO DO: a case for sensitive
    }
    
    func resetButtons(){
        
        self.btnOne.isSelected = false
        self.btnTwo.isSelected = false
        self.btnThree.isSelected = false
        self.btnFour.isSelected = false
                       
        self.btnOne.isEnabled = true
        self.btnTwo.isEnabled = true
        self.btnThree.isEnabled = true
        self.btnFour.isEnabled = true
        
    }
    
    @IBAction func closeTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
