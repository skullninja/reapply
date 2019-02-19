//
//  NotificationService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/8/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService {
    
    static let shared = NotificationService()
    
    private let _notificationCenter = UNUserNotificationCenter.current()
    private let _notificationContent = UNMutableNotificationContent()
    
    init() {
        
    }
    
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
        _notificationContent.subtitle = "Reapplying sunscreen will only take a few minutes."
        _notificationContent.body = "Get on in here and reapply."
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func setupFollowUpTomorrowNotificationContent(_ seconds: Int) {
        let maxUVIndex = Int(ForecastService.shared.fiveDayForecast[1].uvIndex ?? 0)
        let cloudCoverage = Int(ForecastService.shared.fiveDayForecast[1].cloudCoverage! * 100)
        _notificationContent.title = "Good morning, sunshine!"
        //TO DO: get top uv index and cloud coverage
        _notificationContent.subtitle = "Don't forget to apply suncreen today. The top UV Index is \(maxUVIndex) and cloud coverage is \(cloudCoverage) percent."
        _notificationContent.body = "Get on in here and start the sunscreen reminder."
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func setReminderNotification(_ reminder: Reminder) {
        
        removeNotifications()
        
        let seconds = reminder.calculateSecondsToReapply()
        
        _notificationCenter.getNotificationSettings{ (settings) in
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                
                //TODO: notification for tomorrow morning to remind them to use the app
                
                if let sunUp = ReminderService.shared.sunRise {
                    let oneDay = 86400
                    let threeHours = 10800
                    let sunriseLocalTime = sunUp.convertFromGMT(timeZone: TimeZone.current)
                    let tomorrowDate = sunriseLocalTime.addingTimeInterval(TimeInterval(oneDay+threeHours))
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    let secondsUntilTomorrowDate = abs(localTime.timeIntervalSince(tomorrowDate))
                    
                    self.setupFollowUpTomorrowNotificationContent(Int(secondsUntilTomorrowDate))
                    self.createNotification(Int(secondsUntilTomorrowDate))
                    print("tomorow's notification set")
                }
                
                var secondsUntilSunset = 0.0
                
                if let sunDown = ReminderService.shared.sunSet {
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    let checkAhead = localTime.addingTimeInterval(TimeInterval(seconds))
                
                    let sunsetLocalTime = sunDown.convertFromGMT(timeZone: TimeZone.current)
                    secondsUntilSunset = abs(localTime.timeIntervalSince(sunsetLocalTime))
                    
                    // the sun is setting befire the reminder time no need to set a notification
                    if checkAhead > sunDown { return }
                }
                
                self.setupInititalNotificationContent(seconds)
                self.createNotification(seconds)
                
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
    
    func removeNotifications() {
        print("remove notifications")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}
