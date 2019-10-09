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
import Firebase

protocol QuizViewControllerDelegate: AnyObject {
    func quizCompleteWith(_ product: Any, quizViewController: QuizViewController)
}

class QuizViewController: UIViewController {
     
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnOne: MDCButton!
    @IBOutlet weak var btnTwo: MDCButton!
    @IBOutlet weak var btnThree: MDCButton!
    @IBOutlet weak var btnFour: MDCButton!
    
    var questionCounter = 0
    weak var delegate: QuizViewControllerDelegate?
    
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
        
        var buttonTitle = sender.title(for: .normal)
        buttonTitle = buttonTitle?.replacingOccurrences(of: " ", with: "")
        
        let answerTag = buttonTitle!.lowercased()
        self.tagsArray.append(answerTag)
        
        Analytics.logEvent(AnalyticsEvents.quizQuestionAnswered, parameters: [
                   AnalyticsParameterItemName: questionCounter,
                   AnalyticsParameterItemID: answerTag
                   ])
        
        if (questionCounter == 3) {
            if let product = ProductService.shared.productForTags(self.tagsArray) {
                delegate?.quizCompleteWith(product, quizViewController: self)
            }
            return
        }
        
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
        
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            
            self.btnOne.alpha = 0
            self.btnTwo.alpha = 0
            self.btnThree.alpha = 0
            self.btnFour.alpha = 0
            self.lblQuestion.alpha = 0
            
        }, completion: { (finished: Bool) in
            
           self.updateButtonDisplay()
         
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                              self.lblQuestion.alpha = 1.0
                              self.btnOne.alpha = 1.0
                              self.btnTwo.alpha = 1.0
                              self.btnThree.alpha = 1.0
                              self.btnFour.alpha = 1.0
                              
                          }, completion:nil)
         
        })
    
    }
    
    func resetButtonState(){
        
        self.btnOne.isSelected = false
        self.btnTwo.isSelected = false
        self.btnThree.isSelected = false
        self.btnFour.isSelected = false
        
        self.btnFour.isHidden = true
    }
    
    func updateButtonDisplay (){
        
        self.resetButtonState()
        
        //Get the next question and answer options
        questionCounter = questionCounter + 1
              
        //skip question if women and withmakeup has been selected
        if (questionCounter == 2 && self.tagsArray.contains("women") && self.tagsArray.contains("withmakeup")){
              questionCounter = questionCounter + 1
        }
        
        let question = self.questions[questionCounter]
        let questionDict = question as! Dictionary<String, AnyObject>
                      
        let questionText = questionDict["question"] as! String
               
        self.lblQuestion.text = questionText
               
        let answerOptions = questionDict["answers"] as! Array<String>
        
        self.btnOne.setTitle(answerOptions[0], for: .normal)
        self.btnTwo.setTitle(answerOptions[1], for: .normal)
        self.btnThree.setTitle(answerOptions[2], for: .normal)
    
        let answerTag = self.tagsArray[0]
        if ((questionCounter == 1 && answerTag == "women") || questionCounter == 3){
            self.btnFour.isHidden = false
            self.btnFour.setTitle(answerOptions[3], for: .normal)
               
        }
        
        //TO DO: skip 3rd question if women and with makeup is selected
    }
    
    @IBAction func closeTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
