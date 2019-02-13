//
//  ReminderService.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/2/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications

enum StartResponse {
    case started
    case alreadyRunning
    case tooLate
    case tooEarly
}

class ReminderService {
    
    static let shared = ReminderService()
    
    fileprivate var _isTimerRunning = false
    fileprivate var _reminder: Reminder?
    
    //TODO: Watch for change
    var protection: ProtectionLevel = .normal
    var method: SunscreenMethod = .spray
    
    var sunDown: Date?
    var sunUp: Date?
    
    var isRunning: Bool {
        get {
            return _reminder != nil
        }
    }
    
    var currentReminder: Reminder? {
        get {
            return _reminder
        }
    }
    
    init() {
        
    }
    
    func start() -> StartResponse {
        guard !isRunning else { return .alreadyRunning }
        
        if let sunDown = sunDown {
            let checkAhead = Date().addingTimeInterval(60);
            if checkAhead > sunDown { return .tooLate }
            
            //TODO: spend time on this logic
            if checkAhead < sunDown { return .tooEarly }
        }
        
        let reminder = Reminder()
        reminder.method = method
        reminder.protection = protection
        reminder.start = Date()
        reminder.end = sunDown
        
        let seconds = reminder.calculateSecondsToReapply()
        //TODO: Remove this
        reminder.scheduledNotification = Date(timeIntervalSinceNow: TimeInterval(seconds))
        
        NotificationService.shared.setReminderNotification(reminder)

        
        _reminder = reminder
        
        return .started
    }
    
    func stop() {
        _reminder = nil
        print("notifcations removed")
        NotificationService.shared.removeNotifications()
    }
    
    func snooze() {
        //TODO:
    }
    
    func reapply() {
        guard isRunning else { return }
        let seconds = _reminder?.calculateSecondsToReapply() ?? 0
        //TODO: Remove this
        _reminder?.scheduledNotification = Date(timeIntervalSinceNow: TimeInterval(seconds))
        if let reminder = _reminder {
            NotificationService.shared.setReminderNotification(reminder)
        }
    }
    
    private func scheduleNotifications() {
        guard isRunning else { return }
        //TODO: Pass reminder to notification service
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02ihr %02imin %02isec", hours, minutes, seconds)
    }
    
    //Mark - UNNotifcation Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "Reapply" {
            reapply()
        } else if response.actionIdentifier == "Later" {
            snooze()
        } else if response.actionIdentifier == "Stop" {
            stop()
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //remove any notifications
        NotificationService.shared.removeNotifications()
        
        completionHandler([.alert, .sound])
    }
}
