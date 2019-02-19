//
//  ViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 1/22/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit
import ForecastIO
import CoreLocation
import UserNotifications
import ScrollableGraphView

enum protectionLevel:Float {
    case norm = 0.0
    case high = 5.0
    case max = 10.0
}

enum sunscreenType:Float {
    case spray = 0.0
    case cream = 1.0
}

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var lblUVIndex: UILabel!
    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var lblTimerCountdown: UILabel!
    @IBOutlet weak var lblSunriseTime: UILabel!
    @IBOutlet weak var lblSunsetTime: UILabel!
    @IBOutlet weak var lblCurrentProtectionLevel: UILabel!
    @IBOutlet weak var sliderProtectionLevel: UISlider!
    @IBOutlet weak var sliderSunscreenMethod: UISlider!
    @IBOutlet weak var btnStartTimer: UIButton!
    @IBOutlet weak var btnReapply: UIButton!
    @IBOutlet weak var graphContainerView: UIView!
    
    var graphView: ScrollableGraphView?
    
    var sunsetLocalTime = Date()
    var sunriseLocalTime = Date()
    
    var displayTimer: Timer!
    
    let locationManager = CLLocationManager()
    var uvIndexNeedsUpdate: Bool = true
    
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    
    lazy var client: DarkSkyClient = {
        let darkSky = DarkSkyClient(apiKey: "16d1cdbf343ab6a7ee0dcb340b7484ff")
        darkSky.units = .auto
        darkSky.language = .english
        return darkSky
    }()
    
    func activateLocationServices() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    //TODO: Re-enable buttons, etc.
    @objc func updateDisplay() {
        guard ReminderService.shared.isRunning else { return }
        
        if let reapplyDate = ReminderService.shared.currentReminder?.scheduledNotification {
            let interval = Date().timeIntervalSince(reapplyDate)
            lblTimerCountdown.text = timeString(time: interval)
        } else {
            lblTimerCountdown.text = "00hr 00min 00sec"
        }
        
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lblCurrentProtectionLevel.text = "--"
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().delegate = self
        displayTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateDisplay), userInfo: nil, repeats: true)
        RunLoop.current.add(displayTimer, forMode: .common)
        
        ReminderService.shared.method = .cream
        ReminderService.shared.protection = .normal

        updateButtonDisplay(_initialLoad: true)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uvIndexNeedsUpdate = true
        activateLocationServices()
        handleProtectionFilter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadGraph()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func reloadGraph() {
        graphView?.removeFromSuperview()
        graphView = GraphService.createGraphView(frame: graphContainerView.bounds, dataSource: self)
        if let graphView = graphView {
            graphContainerView.addSubview(graphView)
            graphView.leftAnchor.constraint(equalTo: graphContainerView.leftAnchor)
            graphView.rightAnchor.constraint(equalTo: graphContainerView.rightAnchor)
            graphView.topAnchor.constraint(equalTo: graphContainerView.topAnchor)
            graphView.bottomAnchor.constraint(equalTo: graphContainerView.bottomAnchor)
        }
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
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUVIndexIfNeeded(locations[0])
    }
    
    func updateUVIndexIfNeeded(_ location: CLLocation) {
        guard uvIndexNeedsUpdate else { return }
        uvIndexNeedsUpdate = false
        
        //TODO: Update When Day Switches or Location Changes
        client.getForecast(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
            DispatchQueue.main.async {
                if let uvindex = result.value.0?.currently?.uvIndex {
                    self.lblUVIndex.text = String(uvindex)
                }
                
                if let sunsetTime = result.value.0?.daily?.data[0].sunsetTime {
                    //returns at UNIX time, do something here
                    self.sunsetLocalTime = sunsetTime.convertFromGMT(timeZone: TimeZone.current)
                    ReminderService.shared.sunSet = sunsetTime
                    self.lblSunsetTime.text =  result.value.0?.daily?.data[0].sunsetTime?.toString(dateFormat: "h:mm a")
                }
                
                if let sunriseTime = result.value.0?.daily?.data[0].sunriseTime {
                    //returns at UNIX time, do something here
                    
                    self.sunriseLocalTime = sunriseTime.convertFromGMT(timeZone: TimeZone.current)
                    ReminderService.shared.sunRise = sunriseTime
                    self.lblSunriseTime.text =   result.value.0?.daily?.data[0].sunriseTime?.toString(dateFormat: "h:mm a")
                }
            }
        }
        
    }

    @IBAction func setReminderNotification(_ sender: Any) {
        
        switch ReminderService.shared.start() {
        case .alreadyRunning:
            ReminderService.shared.stop()
            lblTimerCountdown.text = "00hr 00min 00sec"
            lblCurrentProtectionLevel.text = "--"
            updateButtonDisplay(_initialLoad: false)
            reloadGraph()
            break
        case .started:
            updateButtonDisplay(_initialLoad: false)
            reloadGraph()
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
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02ihr %02imin %02isec", abs(hours), abs(minutes), abs(seconds))
    }
    
    @IBAction func protectionSliderChanged(_ sender: Any) {
        let fixed = roundf((sender as AnyObject).value / 5.0) * 5.0;
        (sender as AnyObject).setValue(fixed, animated: true)
        
        handleProtectionFilter()
    }
    
    @IBAction func methodSliderChanged(_ sender: Any) {
        let fixed = roundf((sender as AnyObject).value / 1.0) * 1.0;
        (sender as AnyObject).setValue(fixed, animated: true)
    }
    
    func handleProtectionFilter()
    {
        guard let mode = protectionLevel(rawValue: sliderProtectionLevel.value) else {
          return
        }
        
        switch mode {
        case protectionLevel.norm:
            ReminderService.shared.protection = .normal
        case protectionLevel.high:
            ReminderService.shared.protection = .high
        case protectionLevel.max:
           ReminderService.shared.protection = .maximum
        }
    }
    
    func handleMethodFilter()
    {
        guard let mode = sunscreenType(rawValue: sliderSunscreenMethod.value) else {
            return
        }
        
        switch mode {
        case sunscreenType.spray:
            ReminderService.shared.method = .spray
        case sunscreenType.cream:
            ReminderService.shared.method = .cream
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

extension ViewController: ScrollableGraphViewDataSource {
    
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
