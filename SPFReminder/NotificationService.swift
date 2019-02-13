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
        
        _notificationContent.title = "Reminder"
        _notificationContent.subtitle = "\(minutes) minutes have passed"
        _notificationContent.body = "Would you like to continue and reapply sunscreen?"
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func setupFollowUpNotificationContent(_ seconds: Int) {

        _notificationContent.title = "Important Reminder"
        _notificationContent.subtitle = "It's been a while since you applied sunscreen"
        _notificationContent.body = "Would you like to continue and reapply sunblock?"
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func setReminderNotification(_ seconds: Int, sundown: Date) {
        
        _notificationCenter.getNotificationSettings{ (settings) in
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                
                self.setupInititalNotificationContent(seconds)
                var trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                                repeats: false)
                
                var identifier = "InitialNotification"
                let notifcationRequest1 = UNNotificationRequest(identifier: identifier,
                                                    content: self._notificationContent, trigger: trigger)
                self._notificationCenter.add(notifcationRequest1, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went wrong
                    }
                })
                
                //Send a follow up reminder 30 seconds later
                self.setupFollowUpNotificationContent(seconds)
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds + 1800),
                                                            repeats: false)
                identifier = "FollowUpNotification1"
                let notifcationRequest2 = UNNotificationRequest(identifier: identifier,
                                                    content: self._notificationContent, trigger: trigger)
                self._notificationCenter.add(notifcationRequest2, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went wrong
                    }
                })
                
                print("notification added to center at \(seconds) seconds")
            }
        }
    
    }
    
    func removeNotifications() {
        print("remove notifications")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}
