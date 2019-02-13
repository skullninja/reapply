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
                
                if let sunDown = ReminderService.shared.sunSet {
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    let checkAhead = localTime.addingTimeInterval(3600)
                    // the sun is setting soon no need to set a notification
                    if checkAhead > sunDown { return }
                }
                
                self.setupInititalNotificationContent(seconds)
                var trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                                repeats: false)
                
                var identifier = "InitialNotification\(seconds)"
                let notifcationRequest1 = UNNotificationRequest(identifier: identifier,
                                                    content: self._notificationContent, trigger: trigger)
                self._notificationCenter.add(notifcationRequest1, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went wrong
                    }
                })
                
                //Send a follow up reminder 20 and every 45 minutes until sunset
                
                  if let sunDown = ReminderService.shared.sunSet {
                    let localTime = Date().convertFromGMT(timeZone: TimeZone.current)
                    var secondsUntilSunset = abs(localTime.timeIntervalSince(sunDown))
                    let twentyMinutes = 1200
                    let fortyFiveMinutes = 2700
                    
                    //setup first notification at 20 minutes
                    
                    if secondsUntilSunset > 4800{
                        self.setupFollowUpNotificationContent(twentyMinutes)
                        trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds + twentyMinutes),
                                                                repeats: false)
                        identifier = "FollowUpNotification\(seconds+twentyMinutes)"
                        let notifcationRequest2 = UNNotificationRequest(identifier: identifier,
                                                                    content: self._notificationContent, trigger: trigger)
                        self._notificationCenter.add(notifcationRequest2, withCompletionHandler: { (error) in
                            if let error = error {
                                // Something went wrong
                        }
                        })
                        
                        print("follow up notifcation for 20 minutes, \(secondsUntilSunset) remaining")
                        secondsUntilSunset = secondsUntilSunset - Double(twentyMinutes)
                    }
                    
                   
                    while secondsUntilSunset >= 4800 {
                        
                        self.setupFollowUpNotificationContent(fortyFiveMinutes)
                        trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds + fortyFiveMinutes),
                                                                    repeats: false)
                        identifier = "FollowUpNotification\(seconds+fortyFiveMinutes)"
                        let notifcationRequest2 = UNNotificationRequest(identifier: identifier,
                                                                        content: self._notificationContent, trigger: trigger)
                        self._notificationCenter.add(notifcationRequest2, withCompletionHandler: { (error) in
                            if let error = error {
                                // Something went wrong
                            }
                        })
                        
                        print("follow up notifcation for 45 minutes, \(secondsUntilSunset) remaining")
                        secondsUntilSunset = secondsUntilSunset - Double(fortyFiveMinutes)
                    }

                }
            }
        }
    
    }
    
    func removeNotifications() {
        print("remove notifications")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}
