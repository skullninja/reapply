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

class ReminderViewController: UIViewController {
    
    @IBOutlet weak var lblUVIndex: UILabel!
    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var lblTimerCountdown: UILabel!
    //@IBOutlet weak var lblSunriseTime: UILabel!
    //@IBOutlet weak var lblSunsetTime: UILabel!
    //@IBOutlet weak var lblCurrentProtectionLevel: UILabel!
    @IBOutlet weak var btnStartTimer: UIButton!
    @IBOutlet weak var btnReapply: UIButton!
    //@IBOutlet weak var graphContainerView: UIView!
    
    var graphView: ScrollableGraphView?
    
    var configureVC: ConfigureReminderViewController?
    
    var displayTimer: Timer!
    
    var uvIndexNeedsUpdate: Bool = true
    
    //TODO: Re-enable buttons, etc.
    @objc func updateDisplay() {
       
        if let reapplyDate = ReminderService.shared.currentReminder?.scheduledNotification {
            let interval = Date().timeIntervalSince(reapplyDate)
            if interval > 0 {return}
            lblTimerCountdown.text = timeString(time: interval)
        } else {
            lblTimerCountdown.text = "00:00:00"
        }
        
        /*
        let protectionLevel = ReminderService.shared.currentReminder?.protectionLevel(for: Date()) ?? 0.0
        if protectionLevel >= 100.0 {
            lblCurrentProtectionLevel.text = "good"
        } else if protectionLevel > 40.0 {
            lblCurrentProtectionLevel.text = "ok"
        } else if protectionLevel > 0.0 {
            lblCurrentProtectionLevel.text = "poor"
        } else {
            lblCurrentProtectionLevel.text = "--"
        }
        */
        
        if let uvindex = ForecastService.shared.currentUVIndex {
            self.lblUVIndex.text = String(uvindex)
        }
        
        //self.lblSunsetTime.text =  ForecastService.shared.sunsetTime.toString(dateFormat: "h:mm a")
        //self.lblSunriseTime.text = ForecastService.shared.sunriseTime.toString(dateFormat: "h:mm a")
        
        //to do: remove the city label
        LocationService.shared.lookUpCurrentLocation{ geoLoc in
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
        }
        
        updateButtonDisplay(_initialLoad: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //lblCurrentProtectionLevel.text = "--"
        // Do any additional setup after loading the view, typically from a nib.
        displayTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(ReminderViewController.updateDisplay), userInfo: nil, repeats: true)
        RunLoop.current.add(displayTimer, forMode: .common)

        updateButtonDisplay(_initialLoad: true)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uvIndexNeedsUpdate = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadGraph()
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
        
        if _initialLoad{
            //initial load disable the reapply button
            btnReapply.isEnabled = false
            btnReapply.alpha = 0.5
        } else if ReminderService.shared.isRunning {
            //Start button pressed , update title to stop and enable reapply button
            btnReminder.setTitle("Stop", for: .normal)
            btnReapply.isEnabled = true
            btnReapply.alpha = 1
        } else {
            //Stop button pressed and reminder in progress
            btnReminder.setTitle("Start", for: .normal)
            btnReapply.isEnabled = false
            btnReapply.alpha = 0.5
        }
        
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", abs(hours), abs(minutes), abs(seconds))
    }
    
    @IBAction func startStopAction(_ sender: Any) {
        
        /*var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        config.presentationContext = .viewController(self)
        //config.presentationContext = .window(windowLevel: .alert)
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        //config.interactiveHide = false
        //config.preferredStatusBarStyle = .lightContent
        config.eventListeners.append() { event in
            if case .didHide = event { print("yep") }
        }
        */
        
        if ReminderService.shared.isRunning {
            ReminderService.shared.stop()
        } else {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            configureVC = storyboard.instantiateViewController(withIdentifier: "ConfigureReminderViewController") as? ConfigureReminderViewController
            if let configureVC = configureVC {
                let segue = ConfigureReminderSegue(identifier: nil, source: self, destination: configureVC)
                segue.perform()
            }
        }
        
    }
    
    @IBAction func reapplyButtonTapped(_ sender: Any) {
         if ReminderService.shared.isRunning {
            ReminderService.shared.reapply()
            // ensure the stop/start button is enabled and stop is the title
            btnReminder.isEnabled = true
            btnReminder.setTitle("Stop", for: .normal)
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
        dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
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
