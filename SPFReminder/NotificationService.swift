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
    
    func setupNotificationContent(_ seconds: Int) {
        
        let minutes = seconds / 60
        
        _notificationContent.title = "Reminder"
        _notificationContent.subtitle = "\(minutes) minutes have passed"
        _notificationContent.body = "Would you like to continue and reapply sunblock?"
        _notificationContent.badge = 1
        _notificationContent.categoryIdentifier = "spfReminderCategory"
        //_notificationContent = UNNotificationSound.default()
    }
    
    func setReminderNotification(_ seconds: Int) {
        
        _notificationCenter.getNotificationSettings{ (settings) in
            if settings.authorizationStatus == .authorized {
                // Notifications allowed
                
                self.setupNotificationContent(seconds)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                                repeats: false)
                
                let identifier = "UNLocalNotification"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: self._notificationContent, trigger: trigger)
                self._notificationCenter.add(request, withCompletionHandler: { (error) in
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
