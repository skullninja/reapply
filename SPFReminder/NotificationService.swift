//
//  NotificationService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/8/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationService()
    
    private let _notificationCenter = UNUserNotificationCenter.current()
    private let _notificationContent = UNMutableNotificationContent()
    
    func setupInititalNotificationContent(_ seconds: Int) {
        
        let minutes = seconds / 60
        
        _notificationContent.title = "Howdy!"
        _notificationContent.subtitle = "\(minutes) minutes have passed"
        _notificationContent.body = "Would you like to continue and reapply sunscreen?"
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func setupFollowUpNotificationContent(_ seconds: Int) {

        _notificationContent.title = "Hello, sunshine!"
        _notificationContent.subtitle = "Reapplying sunscreen will only take a minute."
        _notificationContent.body = "Get on in here and reapply."
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    
    func setReminderNotification(_ reminder: Reminder) {
        
        UNUserNotificationCenter.current().delegate = self
        removeNotifications()
        
        let seconds = reminder.calculateSecondsToReapply()
        
        _notificationCenter.getNotificationSettings{ (settings) in
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                
                var secondsUntilSunset = 0.0
                
                if let sunDown = ReminderService.shared.sunSet {
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    let checkAhead = localTime.addingTimeInterval(TimeInterval(seconds))
                
                    // the sun is setting before the reminder time no need to set a notification
                    if checkAhead > sunDown { return }
                    
                    //set the initial follow up notifcation
                    self.setupInititalNotificationContent(seconds)
                    self.createNotification(seconds)
                    
                    //used later to calc how many seconds left until sunset with each notification set
                    let sunsetLocalTime = sunDown.convertFromGMT(timeZone: TimeZone.current)
                    secondsUntilSunset = abs(localTime.timeIntervalSince(sunsetLocalTime))
                }
                
                secondsUntilSunset = secondsUntilSunset - Double(seconds)
                print("\(secondsUntilSunset) minutes remaining before sunset")
                
                //Send a follow up reminder 30 and every 60 minutes until sunset
                let thirtyMinutes = 1800
                let sixtyMinutes = 3600
                var notificationTime = seconds+thirtyMinutes
                
                //setup first notification at 30 minutes
                if Int(secondsUntilSunset) > seconds{
                    
                    self.setupFollowUpNotificationContent(thirtyMinutes)
                    self.createNotification(notificationTime)
                    
                    secondsUntilSunset = secondsUntilSunset - Double(thirtyMinutes)
                    print("follow up notifcation for 30 minutes, \(secondsUntilSunset) minutes remaining")
                }
                
                while Int(secondsUntilSunset) > seconds {
                    notificationTime = notificationTime + sixtyMinutes
                    self.setupFollowUpNotificationContent(sixtyMinutes)
                    self.createNotification(notificationTime)
                    
                    secondsUntilSunset = secondsUntilSunset - Double(sixtyMinutes)
                    print("follow up notifcation for 60 minutes, \(secondsUntilSunset) minutes remaining")
                    
                }
                
                self.createFutureDailyNotification()
            }
        }
    
    }
    
    func createNotification(_ seconds: Int){
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                        repeats: false)
        
        let identifier = "InitialNotification\(seconds)"
        let notifcationRequest1 = UNNotificationRequest(identifier: identifier,
                                                        content: self._notificationContent, trigger: trigger)
        self._notificationCenter.add(notifcationRequest1, withCompletionHandler: { (error) in
            if error != nil {
                // Something went wrong
            }
        })
        
    }
    
    func createFutureDailyNotification(){
        
        if let sunUp = ReminderService.shared.sunRise {
            
            //start with index 1 to get tomorrow's forecast
            var i = 1
            while i < ForecastService.shared.fiveDayForecast.count {
               
                let oneDay = 86400
                let threeHours = 10800
                let sunriseLocalTime = sunUp.convertFromGMT(timeZone: TimeZone.current)
                let tomorrowDate = sunriseLocalTime.addingTimeInterval(TimeInterval(oneDay+threeHours))
                let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                let secondsUntilTomorrowDate = abs(localTime.timeIntervalSince(tomorrowDate))
                
                self.setupFutureDailyNotificationContent(Int(secondsUntilTomorrowDate) * i, dayIndex: i)
                self.createNotification(Int(secondsUntilTomorrowDate))
                print("tomorow's notification set")
                i += 1
            }
        }
      
    }
    
    func setupFutureDailyNotificationContent(_ seconds: Int, dayIndex: Int) {
        let maxUVIndex = Int(ForecastService.shared.fiveDayForecast[dayIndex].uvIndex ?? 0)
        let cloudCoverage = Int(ForecastService.shared.fiveDayForecast[dayIndex].cloudCoverage! * 100)
        _notificationContent.title = "Good morning, sunshine!"
        //TO DO: get top uv index and cloud coverage
        _notificationContent.subtitle = "Don't forget to apply suncreen today."
        _notificationContent.body = "The top UV Index is \(maxUVIndex) and cloud coverage is \(cloudCoverage) percent. Get on in here and start the sunscreen reminder."
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func removeNotifications() {
        print("remove notifications")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    //Mark - UNNotifcation Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "Reapply" {
            ReminderService.shared.reapply()
        } else if response.actionIdentifier == "Stop" {
            ReminderService.shared.stop()
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //remove any notifications
        NotificationService.shared.removeNotifications()
        
        completionHandler([.alert, .sound])
    }
    
}
