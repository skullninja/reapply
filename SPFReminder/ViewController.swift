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

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var lblUVIndex: UILabel!
    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var lblTimerCountdown: UILabel!
    
    let locationManager = CLLocationManager()
    var uvIndexNeedsUpdate: Bool = true
    
    let center = UNUserNotificationCenter.current()
    
    var timer = Timer()
    var isTimerRunning = false
    //4800 is 80 minutes
    var seconds = 10
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uvIndexNeedsUpdate = true
        activateLocationServices()
        
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
            }
        }
        
    }

    @IBAction func setReminderNotification(_ sender: Any) {
       setReminderNotification()
    }
    
    func setReminderNotification() {
        
        btnReminder.isEnabled = false
        
        center.getNotificationSettings{ (settings) in
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                let content = UNMutableNotificationContent()
                content.title = "SPF Reminder"
                content.subtitle = "Eighty minutes have passed"
                content.body = "Would you like to continue and reapply sunblock?"
                content.badge = 1
                content.categoryIdentifier = "spfReminderCategory"
                //content.sound = UNNotificationSound.default()
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.seconds),
                                                                repeats: false)
                
                let identifier = "UYLLocalNotification"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                self.center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went wrong
                    }
                })
            }
        }
        
        runTimer()
    }
    
    func runTimer(){
       timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds == 0{
            timer.invalidate()
             btnReminder.isEnabled = true
            lblTimerCountdown.text = "--hr --min"
            return
        }
        seconds -= 1
        lblTimerCountdown.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //Mark - UNNotifcation Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "Reset"{
            //setReminderNotification()
            
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

