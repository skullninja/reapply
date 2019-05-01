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

enum ScreenMode {
    case daytime
    case nightime
    case running
}

class ReminderViewController: UIViewController {
    
    @IBOutlet weak var lblUVIndex: UILabel!
    @IBOutlet weak var lblTimerCountdown: UILabel!
    @IBOutlet weak var lblUVLevel: UILabel!
    @IBOutlet weak var lblUVLevelDescription: UILabel!
    @IBOutlet weak var btnReapply: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    
    @IBOutlet weak var activeHeaderView: UIImageView!
    @IBOutlet weak var transitionHeaderView: UIImageView!
    @IBOutlet weak var nightBackgroundView: UIImageView!
    
    //@IBOutlet weak var graphContainerView: UIView!
    
    let defaultHeaderImage = UIImage(named: "temp-header")
    let timerHeaderImage = UIImage(named: "temp-header-timer")
    let nightHeaderImage = UIImage(named: "temp-header-low-uv")
    
    var graphView: ScrollableGraphView?
    
    var configureVC: ConfigureReminderViewController?
    
    var displayTimer: Timer!
    
    var uvIndexNeedsUpdate: Bool = true
    
    var screenMode: ScreenMode = .daytime
    
    //TODO: Re-enable buttons, etc.
    @objc func updateDisplay() {
        
        if ReminderService.shared.isRunning {
            self.screenMode = .running
        } else if let uvIndex = ForecastService.shared.currentUVIndex,
            uvIndex < 1 {
            self.screenMode = .nightime
        } else {
            self.screenMode = .daytime
        }
       
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
        
        var activeHeaderImage = defaultHeaderImage
        switch self.screenMode {
        case .running:
            activeHeaderImage = timerHeaderImage
            break
        case .nightime:
            activeHeaderImage = nightHeaderImage
            break
        case .daytime:
            // Nothing
            break
        }
        
        if self.transitionHeaderView.image != activeHeaderImage {
            self.transitionHeaderView.image = activeHeaderImage
            UIView.animate(withDuration: 0.3, animations: {
                self.activeHeaderView.alpha = 0.0
            }) { _ in
                self.activeHeaderView.image = activeHeaderImage
                self.activeHeaderView.alpha = 1.0
            }
        }
        
        if let uvIndex = ForecastService.shared.currentUVIndex {
            self.lblUVIndex.text = String(uvIndex)
            var uvLevel = ""
            var uvDescription = "Some Protection Required"
            if uvIndex < 1 {
                uvLevel = "Low"
                uvDescription = "No Protection Needed"
            } else if uvIndex < 3 {
                uvLevel = "Low"
            } else if uvIndex < 6 {
                uvLevel = "Moderate"
            } else if uvIndex < 8 {
                uvLevel = "High"
            } else if uvIndex < 11 {
                uvLevel = "Very High"
            } else {
                uvLevel = "Extreme"
                uvDescription = "Stay Inside!"
            }
        
            self.lblUVLevel.text = uvLevel + " UV Levels"
            self.lblUVLevelDescription.text = uvDescription
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
        lblUVLevel.text = "";
        lblUVLevelDescription.text = "";
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
        
        if _initialLoad {
            
            btnReapply.clipsToBounds = true
            btnApply.clipsToBounds = true
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
        case .running:
            btnReapply.isHidden = false
            btnApply.isHidden = true
            btnStop.isHidden = false
            nightBackgroundView.isHidden = true
            lblTimerCountdown.isHidden = false
        case .nightime:
            btnReapply.isHidden = true
            btnApply.isHidden = true // Flip to false to support triggering the apply at anytime.
            btnStop.isHidden = true
            nightBackgroundView.isHidden = false
            lblTimerCountdown.isHidden = true
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
