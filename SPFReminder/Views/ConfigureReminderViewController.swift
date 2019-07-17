//
//  ConfigureReminderView.swift
//  SPFReminder
//
//  Created by Dave Peck on 3/7/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol ConfigureReminderViewControllerDelegate: AnyObject {
    func didTapStart()
}

enum protectionLevel:Float {
    case norm = 0.0
    case high = 5.0
    case max = 10.0
}

enum sunscreenType:Float {
    case spray = 0.0
    case cream = 1.0
}

class ConfigureReminderViewController: UIViewController {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var sliderProtectionLevel: UISlider!
    @IBOutlet weak var btnStartTimer: UIButton!
    @IBOutlet weak var lblTimerLength: UILabel!
    
    weak var delegate:ConfigureReminderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnStartTimer.clipsToBounds = true
        btnStartTimer.layer.cornerRadius = 8.0
        
        preferredContentSize = CGSize.init(width: 0, height: 350)
        
        updateProtectionFilter(for: ReminderService.shared.protection)
        //updateMethodFilter(for: ReminderService.shared.method)
        
        handleProtectionFilter()
    }
    
    @IBAction func protectionSliderChanged(_ sender: Any) {
        let fixed = roundf((sender as AnyObject).value / 5.0) * 5.0;
        (sender as AnyObject).setValue(fixed, animated: true)
        
        handleProtectionFilter()
    }
    
    @IBAction func methodSliderChanged(_ sender: Any) {
        let fixed = roundf((sender as AnyObject).value / 1.0) * 1.0;
        (sender as AnyObject).setValue(fixed, animated: true)
        
        handleMethodFilter()
    }
    
    func updateProtectionFilter(for level: ProtectionLevel) {
        switch level {
        case .high:
            sliderProtectionLevel.setValue(protectionLevel.high.rawValue, animated: false)
        case .maximum:
            sliderProtectionLevel.setValue(protectionLevel.max.rawValue, animated: false)
        case .normal:
            sliderProtectionLevel.setValue(protectionLevel.norm.rawValue, animated: false)
        }
    }
    
    func handleProtectionFilter()
    {
        guard let mode = protectionLevel(rawValue: sliderProtectionLevel.value) else {
            return
        }
        
        switch mode {
        case protectionLevel.norm:
            ReminderService.shared.protection = .normal
            self.lblTimerLength.text = "2 hrs"
        case protectionLevel.high:
            ReminderService.shared.protection = .high
            self.lblTimerLength.text = "80 mins"
        case protectionLevel.max:
            ReminderService.shared.protection = .maximum
            self.lblTimerLength.text = "40 mins"
        }
    }
    
    func handleMethodFilter()
    {
        
        /*guard let mode = sunscreenType(rawValue: sliderSunscreenMethod.value) else {
            return
        }
        
        switch mode {
        case sunscreenType.spray:
            ReminderService.shared.method = .spray
        case sunscreenType.cream:
            ReminderService.shared.method = .cream
        }
 */
    }
    
    @IBAction func setReminderNotification(_ sender: Any) {
        
        switch ReminderService.shared.start() {
        case .alreadyRunning:
            ReminderService.shared.stop()
            break
        case .started:
            Analytics.logEvent(AnalyticsEvents.timerStarted, parameters: nil)
            self.logSliderEvent()
            break
        case .tooLate:
            let alert = UIAlertController(title: "Uh oh, it's after sunset", message: "There is no need to apply sunscreen at this time. Try again after sunrise.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case .tooEarly:
            let alert = UIAlertController(title: "Uh oh, it's too early", message: "There is no need to apply sunscreen at this time. Try again after sunrise.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        }
        
       dismiss(animated: true, completion: {
        self.delegate?.didTapStart()
        
       })
    }
    
    
    func logSliderEvent()
    {
        guard let mode = protectionLevel(rawValue: sliderProtectionLevel.value) else {
            return
        }
        
        switch mode {
        case protectionLevel.norm:
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "ProtectionLevelNormal",
                AnalyticsParameterItemName: "slider",
                AnalyticsParameterContentType: "timer"
                ])
        case protectionLevel.high:
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "ProtectionLevelHigh",
                AnalyticsParameterItemName: "slider",
                AnalyticsParameterContentType: "timer"
                ])
        case protectionLevel.max:
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "ProtectionLevelMax",
                AnalyticsParameterItemName: "slider",
                AnalyticsParameterContentType: "timer"
                ])
        }
    }
}
