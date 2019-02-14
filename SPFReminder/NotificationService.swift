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
        
        _notificationContent.title = "Hiya!"
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
    
    func setReminderNotification(_ reminder: Reminder) {
        
        removeNotifications()
        
        let seconds = reminder.calculateSecondsToReapply()
        
        _notificationCenter.getNotificationSettings{ (settings) in
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                
                var secondsUntilSunset = 0.0
                
                if let sunDown = ReminderService.shared.sunSet {
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    let checkAhead = localTime.addingTimeInterval(TimeInterval(seconds))
                
                    secondsUntilSunset = abs(localTime.timeIntervalSince(sunDown))
                    
                    // the sun is setting befire the reminder time no need to set a notification
                    if checkAhead > sunDown { return }
                }
                
                self.setupInititalNotificationContent(seconds)
                self.createNotification(seconds)
                
                secondsUntilSunset = secondsUntilSunset - Double(seconds)
                print("\(secondsUntilSunset) minutes remaining before sunset")
                
                //Send a follow up reminder 20 and every 45 minutes until sunset
                let twentyMinutes = 1200
                let fortyFiveMinutes = 2700
                
                //setup first notification at 20 minutes
                if Int(secondsUntilSunset) > seconds{
                    
                    self.setupFollowUpNotificationContent(twentyMinutes)
                    self.createNotification(twentyMinutes)
                    
                    secondsUntilSunset = secondsUntilSunset - Double(twentyMinutes)
                    print("follow up notifcation for 20 minutes, \(secondsUntilSunset) minutes remaining")
                }
                
                while Int(secondsUntilSunset) > seconds {
                    
                    self.setupFollowUpNotificationContent(fortyFiveMinutes)
                    self.createNotification(fortyFiveMinutes)
                    
                    secondsUntilSunset = secondsUntilSunset - Double(fortyFiveMinutes)
                    print("follow up notifcation for 45 minutes, \(secondsUntilSunset) minutes remaining")
                    
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
