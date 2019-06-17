//
//  ReminderViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 1/22/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit
import ForecastIO
import ScrollableGraphView
import SwiftMessages
import Presentr
import UserNotifications
import Pulsator

class ReminderViewController: GenericViewController {
    
    @IBOutlet weak var lblUVIndex: UILabel!
    @IBOutlet weak var lblTimerCountdown: UILabel!
    @IBOutlet weak var lblUVLevel: UILabel!
    @IBOutlet weak var lblUVLevelDescription: UILabel!
    @IBOutlet weak var btnReapply: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var nightBackgroundView: UIImageView!
    @IBOutlet weak var titleView: UIImageView!
    @IBOutlet weak var lblUntilNextReapply: UILabel!
    @IBOutlet weak var lblTopUVIndex: UILabel!
    
    @IBOutlet weak var lblNow: UILabel!
    @IBOutlet weak var lblToday: UILabel!
    @IBOutlet weak var imgSunUV: UIImageView!
    @IBOutlet weak var lblTopUVTime: UILabel!
    
    @IBOutlet weak var imgSafety: UIImageView!
    @IBOutlet weak var imgApplyBackground: UIButton!
    
    let defaultTitleImage = UIImage(named: "default-title")
    let timerTitleImage = UIImage(named: "timer-title")
    let nightTitleImage = UIImage(named: "night-title")
    
    let presenter = Presentr(presentationType: .alert)
    
    let pulsatorDarkOrange = Pulsator()
    let pulsatorLightOrange = Pulsator()
    let pulsatorYellow = Pulsator()
    
    var graphView: ScrollableGraphView?
    
    var configureVC: ConfigureReminderViewController?
    
    var uvIndexNeedsUpdate: Bool = true
    
    lazy var locationAlertController: AlertViewController = {
        let font = UIFont.boldSystemFont(ofSize: 16)
        let alertController = AlertViewController(title: "Enable Location Services", body: "The experience works best when we know your location. Enabling allows us to get accurate weather data.", titleFont: nil, bodyFont: nil, buttonFont: nil)
        let cancelAction = AlertAction(title: "NO, SORRY! 😱", style: .cancel) {
            print("CANCEL!!")
        }
        let okAction = AlertAction(title: "YES, PLEASE! 🤘", style: .destructive) {
            LocationService.shared.activateLocationServices()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        return alertController
    }()
    
    lazy var notificationAlertController: AlertViewController = {
        let font = UIFont.boldSystemFont(ofSize: 20)
        let alertController = AlertViewController(title: "Enable Notifications", body: "Enabling notifications allows us to alert you when it's time to reapply sunscreen.", titleFont: nil, bodyFont: nil, buttonFont: nil)
        let cancelAction = AlertAction(title: "NO, SORRY! 😱", style: .cancel) {
            print("CANCEL!!")
        }
        let okAction = AlertAction(title: "YES, PLEASE! 🤘", style: .destructive) {
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert]
            
            center.requestAuthorization(options: options) {
                (granted, error) in
                if !granted {
                    print("Something went wrong")
                }
                
                if let currentReminder = ReminderService.shared.currentReminder{
                    NotificationService.shared.setReminderNotification(currentReminder)
                }
                
                let choiceA = UNNotificationAction(identifier: "Reapply", title: "I'm Reapplying Now", options: [.foreground])
                let choiceB = UNNotificationAction(identifier: "Stop", title: "End Reminders", options: [.foreground])
                
                let spfReminderCategory = UNNotificationCategory(identifier: "spfReminderCategory", actions: [choiceA, choiceB], intentIdentifiers: [], options: [])
                
                UNUserNotificationCenter.current().setNotificationCategories([spfReminderCategory])
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        return alertController
    }()
    
    //TODO: Re-enable buttons, etc.
    override func updateDisplay(animate: Bool) {
        super.updateDisplay(animate: animate)
        
        switch self.screenMode {
        case .running:
            titleView.image = timerTitleImage
        case .nightime:
            titleView.image = nightTitleImage
        case .daytime:
            titleView.image = defaultTitleImage
        }
       
        if let reapplyDate = ReminderService.shared.currentReminder?.scheduledNotification {
            let interval = Date().timeIntervalSince(reapplyDate)
            if interval > 0 {
                //positive number means we are past the timer time
                lblTimerCountdown.text = "00:00:00"
                if interval > 4800{
                    //a lot of time has past. lets reset the state of the timer.
                    ReminderService.shared.stop()
                }
                return
            }
            lblTimerCountdown.text = timeString(time: interval)
        } else {
            lblTimerCountdown.text = "00:00:00"
        }
        
        if let uvIndex = ForecastService.shared.currentUVIndex {
            self.lblUVIndex.text = String(format: "%g", uvIndex)
            self.lblTopUVIndex.text = String(format: "%g",ForecastService.shared.maxUVIndex!)
            var uvLevel = ""
            var uvDescription = "Some Protection Required"
            if uvIndex == 0 {
                uvLevel = "Zero"
                uvDescription = "No Protection Needed"
            }
            if uvIndex == 1 {
                uvLevel = "Low"
                uvDescription = "No Protection Needed"
            } else if uvIndex < 3 {
                uvLevel = "Low"
            } else if uvIndex < 6 {
                uvLevel = "Moderate"
                uvDescription = "Protection Required"
            } else if uvIndex < 9 {
                uvLevel = "High"
                 uvDescription = "Protection Required"
            } else {
                uvLevel = "Extremely High"
                uvDescription = "Stay Indoors"
            }
        
            self.lblUVLevel.text = uvLevel + " UV Levels"
            self.lblUVLevelDescription.text = uvDescription
        }
        
        LocationService.shared.lookUpCurrentLocation{ geoLoc in
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
        }
        
        updateButtonDisplay(_initialLoad: false)
    }

    override func viewDidLoad() {
        lblUVLevel.text = "";
        lblUVLevelDescription.text = "";
        super.viewDidLoad()
        
       updateButtonDisplay(_initialLoad: true)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        uvIndexNeedsUpdate = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Inner layer
        imgApplyBackground.layer.insertSublayer(pulsatorDarkOrange, at: 0)
        pulsatorDarkOrange.numPulse = 2
        pulsatorDarkOrange.radius = 90.0
        pulsatorDarkOrange.backgroundColor = UIColor(red: 232/255.0, green: 149/255.0, blue: 76/255.0, alpha: 1).cgColor
        pulsatorDarkOrange.animationDuration = 8
        pulsatorDarkOrange.position = CGPoint(x:imgApplyBackground.bounds.midX, y:imgApplyBackground.bounds.midY)
        
        //Middle layer
        imgApplyBackground.layer.insertSublayer(pulsatorLightOrange, at: 0)
        pulsatorLightOrange.numPulse = 2
        pulsatorLightOrange.radius = 100.0
        pulsatorLightOrange.backgroundColor = UIColor(red: 240/255.0, green: 176/255.0, blue: 95/255.0, alpha: 1).cgColor
        pulsatorLightOrange.animationDuration = 8
        //pulsatorLightOrange.pulseInterval = 5
        pulsatorLightOrange.position = CGPoint(x:imgApplyBackground.bounds.midX, y:imgApplyBackground.bounds.midY)
        
        //Outer Layer
        imgApplyBackground.layer.insertSublayer(pulsatorYellow, at: 0)
        pulsatorYellow.numPulse = 2
        pulsatorYellow.radius = 110.0
        pulsatorYellow.backgroundColor = UIColor(red: 244/255.0, green: 212/255.0, blue: 141/255.0, alpha: 1).cgColor
        pulsatorYellow.animationDuration = 8
        pulsatorYellow.position = CGPoint(x:imgApplyBackground.bounds.midX, y:imgApplyBackground.bounds.midY)
        
      
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.pulsatorLightOrange.start()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
            self.pulsatorYellow.start()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            self.pulsatorDarkOrange.start()
        }
        
        
        if !UserHelper.shared.hasCompletedOnboarding(){
            UserHelper.shared.setOnboardingComplete()
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController") as UIViewController
                
                self.present(viewController, animated: false, completion: nil)
        }
        
        if !UserHelper.shared.seenLocationRequest(){
             customPresentViewController(presenter, viewController: locationAlertController, animated: true, completion:{UserHelper.shared.setLocationRequestComplete()})
        }
 
        //reloadGraph()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.shared.locationManager.stopUpdatingLocation()
    }
    
    func reloadGraph() {
        /*
        graphView?.removeFromSuperview()
        graphView = GraphService.createGraphView(frame: graphContainerView.bounds, dataSource: self)
        if let graphView = graphView {
            graphContainerView.addSubview(graphView)
            graphView.leftAnchor.constraint(equalTo: graphContainerView.leftAnchor)
            graphView.rightAnchor.constraint(equalTo: graphContainerView.rightAnchor)
            graphView.topAnchor.constraint(equalTo: graphContainerView.topAnchor)
            graphView.bottomAnchor.constraint(equalTo: graphContainerView.bottomAnchor)
        }
         */
    }
    
    func updateButtonDisplay(_initialLoad: Bool){
        
        if _initialLoad {
            
            btnReapply.clipsToBounds = true
            //btnApply.clipsToBounds = true
            btnStop.clipsToBounds = true
            btnReapply.layer.cornerRadius = btnReapply.bounds.width / 2.0
            btnApply.layer.cornerRadius = btnApply.bounds.width / 2.0
            btnStop.layer.cornerRadius = btnStop.bounds.width / 2.0
        }
        
        switch self.screenMode {
        case .daytime:
            btnReapply.isHidden = true
            btnApply.isHidden = false
            btnStop.isHidden = true
            nightBackgroundView.isHidden = true
            lblTimerCountdown.isHidden = true
            
            lblUVIndex.isHidden = false
            lblTopUVIndex.isHidden = false
            lblNow.isHidden = false
            lblToday.isHidden = false
            imgSunUV.isHidden = false
            lblTopUVTime.isHidden = false
            imgApplyBackground.isHidden = false
            
            lblUntilNextReapply.isHidden = true
            imgSafety.isHidden = true
            
        case .running:
            btnReapply.isHidden = false
            lblUntilNextReapply.isHidden = false
            btnApply.isHidden = true
            btnStop.isHidden = false
            nightBackgroundView.isHidden = true
            lblTimerCountdown.isHidden = false
            imgApplyBackground.isHidden = true
            imgSafety.isHidden = false
            
            if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 1334 {
                //iPhone 6/6S/7/8
                btnReapply.isHidden = true
                for constraint in self.view.constraints {
                    if constraint.identifier == "StopTopConstraint" {
                        constraint.constant = -80
                    }
                }
        
            }
            
        case .nightime:
            btnReapply.isHidden = true
            lblUntilNextReapply.isHidden = true
            btnApply.isHidden = true // Flip to false to support triggering the apply at anytime.
            btnStop.isHidden = true
            nightBackgroundView.isHidden = false
            lblTimerCountdown.isHidden = true
            imgApplyBackground.isHidden = true
            lblUVIndex.isHidden = true
            lblTopUVIndex.isHidden = true
            lblNow.isHidden = true
            lblToday.isHidden = true
            imgSunUV.isHidden = true
            lblTopUVTime.isHidden = true
            imgSafety.isHidden = true
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", abs(hours), abs(minutes), abs(seconds))
    }
    
    @IBAction func startStopAction(_ sender: Any) {
        
        if ReminderService.shared.isRunning {
            ReminderService.shared.stop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.pulsatorLightOrange.start()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
                self.pulsatorYellow.start()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                self.pulsatorDarkOrange.start()
            }
            
        } else {
            
            self.pulsatorYellow.stop()
            self.pulsatorDarkOrange.stop()
            self.pulsatorLightOrange.stop()
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            configureVC = storyboard.instantiateViewController(withIdentifier: "ConfigureReminderViewController") as? ConfigureReminderViewController
            configureVC?.delegate = self
            if let configureVC = configureVC {
                let segue = ConfigureReminderSegue(identifier: nil, source: self, destination: configureVC)
                segue.perform()
            }
        }
        
    }
    
    @IBAction func reapplyButtonTapped(_ sender: Any) {
        
        //blink timer countdown lable to indicate it's being reset
        self.lblTimerCountdown.alpha = 1.0
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseInOut], animations: {
            self.lblTimerCountdown.alpha = 0.0
        },  completion:  { (finished: Bool) in
            UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseInOut], animations: {
                self.lblTimerCountdown.alpha = 1.0
                },  completion: nil)
        })
        
        
         if ReminderService.shared.isRunning {
            ReminderService.shared.reapply()
            // ensure the stop/start button is enabled and stop is the title
            reloadGraph()
        }
    }
}

extension ReminderViewController: ScrollableGraphViewDataSource {
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return ReminderService.shared.currentReminder?.dataPoints()[pointIndex] ?? 0.0
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return "\(pointIndex + 1)"
    }
    
    func numberOfPoints() -> Int {
        return ReminderService.shared.currentReminder?.dataPoints().count ?? 0
    }
}

class ConfigureReminderSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
        dimMode = .color(color: UIColor(red: 243.0/255.0, green: 114.0/255.0, blue: 37.0/255.0, alpha: 0.8), interactive: true)
        // Increase the internal layout margins. With the `.background` containment option,
        // the margin additions specify the outer margins around `messageView.backgroundView`.
        messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Collapse layout margin edges that encroach on non-zero safe area insets.
        messageView.collapseLayoutMarginAdditions = true
        
        // Add a default drop shadow.
        messageView.configureDropShadow()
        
        // Indicate that the view controller's view should be installed
        // as the `backgroundView` of `messageView`.
        containment = .background
        messageView.configureNoDropShadow()
        
        
    }
}

extension ReminderViewController: ConfigureReminderViewControllerDelegate {
    func didTapStart() {
        if !UserHelper.shared.seenNotificationRequest(){
            customPresentViewController(presenter, viewController: notificationAlertController, animated: true, completion:{
                UserHelper.shared.setNotificationRequestComplete()
                return
            })
        }
    }
}
