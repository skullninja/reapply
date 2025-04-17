//
//  NotificationService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/8/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationService()
    
    private let _notificationCenter = UNUserNotificationCenter.current()
    private let _notificationContent = UNMutableNotificationContent()
    
    private lazy var tips: NSArray = {
        if let path = Bundle.main.path(forResource: "tips", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            return jsonResult as? NSArray ?? NSArray()
        }
        return NSArray()
    }()
    
    func setupInititalNotificationContent(_ seconds: Int) {
        
        let minutes = seconds / 60
        
        _notificationContent.title = "Howdy!"
        _notificationContent.body = "It's time to reapply sunscreen."
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        
         _notificationContent.subtitle = "\(minutes) minutes have passed"
        
        if minutes == 120{
             _notificationContent.subtitle = "2 hours have passed"
        }
    }
    
    func setupFollowUpNotificationContent(_ seconds: Int) {
        _notificationContent.title = "Hello, sunshine!"
        _notificationContent.subtitle = "Reapplying sunscreen will only take a minute."
        _notificationContent.body = "Get on in here and reapply."
        _notificationContent.categoryIdentifier = "spfReminderCategory"
    }
    
    func setupTipNotificationContent(_ tipDescripition: String) {
        _notificationContent.title = "Sun Safety Tip"
        _notificationContent.subtitle = "Do you know?"
        _notificationContent.body = tipDescripition
        _notificationContent.categoryIdentifier = "spfTipCategory"
    }
    
    func setReminderNotification(_ reminder: Reminder) {
        
        UNUserNotificationCenter.current().delegate = self
        let seconds = reminder.calculateSecondsToReapply()
        
        Task {
            let settings = await _notificationCenter.notificationSettings()
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                
                var secondsUntilSunset = 0.0
                let thirtyMinutes = 1800
                let sixtyMinutes = 3600
                
                if let sunDown = ReminderService.shared.sunSet {
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    let checkAhead = localTime.addingTimeInterval(TimeInterval(seconds + sixtyMinutes))
                
                    // the sun is setting to close to the reminder, no need to set a notification
                    if checkAhead > sunDown { return }
                    
                    //set the initial follow up notifcation
                    self.setupInititalNotificationContent(seconds)
                    self.createNotification(seconds)
                    
                    //used later to calc how many seconds left until sunset with each notification set
                    let sunsetLocalTime = sunDown.convertFromGMT(timeZone: TimeZone.current)
                    secondsUntilSunset = abs(localTime.timeIntervalSince(sunsetLocalTime))
                }
                
                secondsUntilSunset = secondsUntilSunset - Double(seconds)
               // print("\(secondsUntilSunset) minutes remaining before sunset")
                
                //Send a follow up reminder 30 and every 60 minutes until sunset
              var notificationTime = seconds+thirtyMinutes
                
                //setup first notification at 30 minutes
                if Int(secondsUntilSunset) > seconds{
                    
                    self.setupFollowUpNotificationContent(thirtyMinutes)
                    self.createNotification(notificationTime)
                    
                    secondsUntilSunset = secondsUntilSunset - Double(thirtyMinutes)
                }
                
                //only set a notification if there is more than hour before sunset after the notification fires
                while Int(secondsUntilSunset) > (seconds + sixtyMinutes) {
                    notificationTime = notificationTime + sixtyMinutes
                    self.setupFollowUpNotificationContent(sixtyMinutes)
                    self.createNotification(notificationTime)
                    
                    secondsUntilSunset = secondsUntilSunset - Double(sixtyMinutes)
                    //print("follow up notifcation for 60 minutes, \(secondsUntilSunset) minutes remaining")
                    
                }
                
                self.createFutureDailyNotification()
                
                if !UserHelper.shared.hasTipNotificationsScheduled(){
                    UserHelper.shared.setTipNotificationsScheduled()
                    self.createTipsNotification()
                }
            }
        }
    
    }
    
    func createNotification(_ seconds: Int){
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                        repeats: false)
        
        let identifier = "Reminder\(seconds)"
        
        self._notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notification-sound.caf"))
  
        let notifcationRequest1 = UNNotificationRequest(identifier: identifier,
                                                        content: self._notificationContent, trigger: trigger)
        self._notificationCenter.add(notifcationRequest1, withCompletionHandler: { (error) in
            print("added notification \(identifier)")
            if error != nil {
                // Something went wrong
                print("something went wrong adding notification")
            }
        })
        
    }
    
    func createFutureDailyNotification(){
        
        removeTomorrowNotifications()
        
        //start with index 1 to get tomorrow's forecast
        var i = 1
        
        while i < min(6, ForecastService.shared.fiveDayForecast.count) {
            
            //if the max uv index is 2 or less or cloud coverage is 90% of more --> continue
            if Int(ForecastService.shared.fiveDayForecast[i].uvIndex ?? 0) <= 2 {continue}
            //WeatherKit does not forecast cloud coverage
            //if Int(ForecastService.shared.fiveDayForecast[i].cloudCoverage! * 100) >= 90 {continue}
        
            //get next day noon
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd.yyyy"
            let result = String(format: "%@ 8:00:00",formatter.string(from: date))
            formatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
            let newdate = formatter.date(from: result)
            let localTomorrow = Calendar.current.date(byAdding: .day, value: i, to: newdate!)!.convertFromGMT(timeZone: TimeZone.current)
            let localNow = Date().convertFromGMT(timeZone: TimeZone.current)
            let secondsUntilTomorrowDate = abs(localNow.timeIntervalSince(localTomorrow))
            self.setupFutureDailyNotificationContent(dayIndex: i)
           // self.createNotification(Int(secondsUntilTomorrowDate))
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilTomorrowDate),
                                                            repeats: false)
            print("added notification TomorrowReminder\(secondsUntilTomorrowDate)")
            
            self._notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notification-sound.caf"))
            
            let notifcationRequest1 = UNNotificationRequest(identifier: "TomorrowReminder\(secondsUntilTomorrowDate)",
                                                            content: self._notificationContent, trigger: trigger)
            self._notificationCenter.add(notifcationRequest1, withCompletionHandler: { (error) in
                if error != nil {
                    // Something went wrong
                }
               
            })
            
            i += 1
        }
    }
    
    func setupFutureDailyNotificationContent(dayIndex: Int) {
        let maxUVIndex = Int(ForecastService.shared.fiveDayForecast[dayIndex].uvIndex ?? 0)
        _notificationContent.title = "Good morning, sunshine!"
        //TODO: get top uv index and cloud coverage
        _notificationContent.subtitle = "Don't forget to apply suncreen today."
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        
        var uvDescription = ""
       if maxUVIndex <= 2 {
            uvDescription = "A sunburn is possible within 60 minutes."
        } else if maxUVIndex <= 5 {
            uvDescription = "A sunburn is possible within 30 to 45 minutes."
        }else if maxUVIndex <= 7 {
            uvDescription = "A sunburn is possible within 15 to 25 minutes."
        } else {
            uvDescription = "A sunburn is possible within 15 minutes."
        }
        
        _notificationContent.body = "The peak UV Level is \(maxUVIndex) today. \(uvDescription)"
    }
    
    func removeReminderNotifications() {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            var identifiersArray: [String] = []
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier .contains("Reminder")  {
                    identifiersArray.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
        }
    }
    
    func removeTomorrowNotifications() {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            var identifiersArray: [String] = []
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier .contains("TomorrowReminder")  {
                    identifiersArray.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
        }
    }
    
    //Mark - UNNotifcation Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "Reapply" {
            Analytics.logEvent(AnalyticsEvents.notificationReapplyTapped, parameters: nil)
            ReminderService.shared.reapply()
        } else if response.actionIdentifier == "Stop" {
            ReminderService.shared.stop()
            Analytics.logEvent(AnalyticsEvents.notificationStopTapped, parameters: nil)
        } else {
            Analytics.logEvent(AnalyticsEvents.notificationTapped, parameters: nil)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //remove any notifications
        NotificationService.shared.removeReminderNotifications()
        
        completionHandler([.alert, .sound])
    }
    
    func createTipsNotification(){
        
        var i = 1
        
        for tip in self.tips{
            
            let tipDict = tip as! Dictionary<String, AnyObject>
            let tipDescription = tipDict["tip"] as! String
            let tipId = tipDict["tipId"]
            self.setupTipNotificationContent(tipDescription )
            
            //get next day noon
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd.yyyy"
            let result = String(format: "%@ 11:59:00",formatter.string(from: date))
            formatter.dateFormat = "MM.dd.yyyy HH:mm:ss"
            let newdate = formatter.date(from: result)
            let localTomorrow = Calendar.current.date(byAdding: .day, value: i, to: newdate!)!.convertFromGMT(timeZone: TimeZone.current)
            let localNow = Date().convertFromGMT(timeZone: TimeZone.current)
            let seconds = abs(localNow.timeIntervalSince(localTomorrow))
           
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                            repeats: false)
            
            self._notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notification-sound.caf"))
            
            let notifcationRequest1 = UNNotificationRequest(identifier: "Tips\(seconds)",
                                                            content: self._notificationContent, trigger: trigger)
            self._notificationCenter.add(notifcationRequest1, withCompletionHandler: { (error) in
                if error != nil {
                    print("error adding tip notificaitons")
                }
                
            })
            
            i += 2
            
            UserHelper.shared.setKeyInUserDefaults(key: tipId as! String, value: "true")
        
        }
    }
    
}
