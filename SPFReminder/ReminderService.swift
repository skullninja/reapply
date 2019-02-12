//
//  ReminderService.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/2/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications



class ReminderService {
    
    static let shared = ReminderService()
    
    fileprivate var _isTimerRunning = false
    fileprivate var _nextReapplyDate: Date?
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
    
    var nextReapply: Date? {
        get {
            return _nextReapplyDate
        }
    }
    
    var currentReminder: Reminder? {
        get {
            return _reminder
        }
    }
    
    init() {
        
    }
    
    func start() {
        guard !isRunning else { return }
        let seconds = calculateSecondsToReapply()
        
        let reminder = Reminder()
        reminder.method = method
        reminder.protection = protection
        reminder.start = Date()
        reminder.end = sunDown
        
        NotificationService.shared.setReminderNotification(seconds)
        reminder.scheduledNotification = Date(timeIntervalSinceNow: TimeInterval(seconds))
        
        _reminder = reminder
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
        let seconds = calculateSecondsToReapply()
        NotificationService.shared.removeNotifications()
        NotificationService.shared.setReminderNotification(seconds)
        _reminder?.scheduledNotification = Date(timeIntervalSinceNow: TimeInterval(seconds))
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
    
    private func calculateSecondsToReapply() -> Int {
    
        var seconds = 0
    
        switch method {
        case .spray:
            seconds += 3600
            break
        case .cream:
            seconds += 4800
            break
        }
        
        switch protection {
        case .normal:
            break
        case .high:
            seconds = Int(Double(seconds) * 0.75)
            break
        case .maximum:
            seconds = Int(Double(seconds) * 0.5)
            break
        }
        
        return seconds
    
    }
}
