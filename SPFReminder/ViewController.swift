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
    @IBOutlet weak var sliderProtectionLevel: UISlider!
    @IBOutlet weak var sliderSunscreenMethod: UISlider!
    @IBOutlet weak var btnStartTimer: UIButton!
    
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
        
        if let reapplyDate = ReminderService.shared.nextReapply {
            let interval = Date().timeIntervalSince(reapplyDate)
            lblTimerCountdown.text = timeString(time: interval)
        } else {
            lblTimerCountdown.text = "00hr 00min 00sec"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().delegate = self
        displayTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateDisplay), userInfo: nil, repeats: true)
        RunLoop.current.add(displayTimer, forMode: .common)
        
        ReminderService.shared.method = .cream
        ReminderService.shared.protection = .normal
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uvIndexNeedsUpdate = true
        activateLocationServices()
        handleProtectionFilter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUVIndexIfNeeded(locations[0])
    }
    
    func updateUVIndexIfNeeded(_ location: CLLocation) {
        guard uvIndexNeedsUpdate else { return }
        uvIndexNeedsUpdate = false
        
        client.getForecast(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
            DispatchQueue.main.async {
                if let uvindex = result.value.0?.currently?.uvIndex {
                    self.lblUVIndex.text = String(uvindex)
                }
                
                if let sunsetTime = result.value.0?.daily?.data[0].sunsetTime {
                    //returns at UNIX time, do something here
                    self.sunsetLocalTime = sunsetTime.convertFromGMT(timeZone: TimeZone.current)
                    self.lblSunsetTime.text =  result.value.0?.daily?.data[0].sunsetTime?.toString(dateFormat: "h:mm a")
                }
                
                if let sunriseTime = result.value.0?.daily?.data[0].sunriseTime {
                    //returns at UNIX time, do something here
                    self.sunriseLocalTime = sunriseTime.convertFromGMT(timeZone: TimeZone.current)
               
                    self.lblSunriseTime.text =   result.value.0?.daily?.data[0].sunriseTime?.toString(dateFormat: "h:mm a")
                }
            }
        }
        
    }

    @IBAction func setReminderNotification(_ sender: Any) {
        
        if ReminderService.shared.isRunning {
            ReminderService.shared.stop()
            btnReminder.setTitle("Start", for: .normal)
        } else {
            //ReminderService.shared.protection = .high
            //ReminderService.shared.method = .cream
            ReminderService.shared.start()
            btnReminder.setTitle("Stop", for: .normal)
        }
        
        //ReminderService.shared.snooze()
        
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02ihr %02imin %02isec", hours, minutes, seconds)
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
        
        /*
        switch mode {
        case protectionLevel.norm:
            ReminderService.shared.protection = .normal
        case protectionLevel.high:
            ReminderService.shared.protection = .high
        case protectionLevel.max:
           ReminderService.shared.protection = .maximum
        }
 */
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
    
}

