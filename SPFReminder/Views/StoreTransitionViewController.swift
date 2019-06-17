//
//  StoreTransitionViewController.swift
//  SPFReminder
//
//  Created by Dave Peck on 5/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

class StoreTransitionViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var roundHeaderView: UIView!
    
    @IBOutlet weak var backgroundBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundHeaderTopConstraint: NSLayoutConstraint!
    
    let roundHeaderConstraintMinValue: CGFloat = 64.0
    var roundHeaderConstraintMaxValue: CGFloat = 500.0
    
    let backgroundConstraintMinValue: CGFloat = 190.0
    let backgroundConstraintMaxValue: CGFloat = -190.0
    
    let defaultHeaderImage = UIImage(named: "default")
    let timerHeaderImage = UIImage(named: "timer")
    let nightHeaderImage = UIImage(named: "night")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundHeaderConstraintMaxValue = UIScreen.main.bounds.size.height - 300.0
        
        //TODO: Refactor
        if ReminderService.shared.isRunning {
            backgroundView.image = timerHeaderImage
        } else if let uvIndex = ForecastService.shared.currentUVIndex,
            uvIndex < 1 {
            backgroundView.image = nightHeaderImage
        } else {
            backgroundView.image = defaultHeaderImage
        }
    }
    
    public func updateForMinValues() {
        roundHeaderTopConstraint.constant = roundHeaderConstraintMinValue
        backgroundBottomConstraint.constant = backgroundConstraintMinValue
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    }
    
    public func updateForMaxValues() {
        roundHeaderTopConstraint.constant = roundHeaderConstraintMaxValue
        backgroundBottomConstraint.constant = backgroundConstraintMaxValue
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    }
}
