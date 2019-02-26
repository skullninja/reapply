//
//  ReminderService.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/2/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

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
    
    var protection: ProtectionLevel = .normal
    var method: SunscreenMethod = .spray
    
    var sunSet: Date?
    var sunRise: Date?
    
    var location: CLLocation?
    
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
        
        if let sunDown = sunSet {
            let currentDate = Date();
            print("now:\(currentDate) and sunset:\(sunDown)")
            if currentDate > sunDown { return .tooLate }
        }
        
        if let sunUp = sunRise {
            let currentDate = Date();
            if currentDate < sunUp { return .tooEarly }
        }
        
        let reminder = Reminder()
        reminder.method = method
        reminder.protection = protection
        reminder.start = Date();
        reminder.end = sunSet
        
        reminder.updateScheduledNotification()
        NotificationService.shared.setReminderNotification(reminder)

        _reminder = reminder
        
        return .started
    }
    
    func stop() {
        _reminder = nil
        print("notifcations removed")
        NotificationService.shared.removeNotifications()
    }
    
    func reapply() {
        guard isRunning else { return }
        if let reminder = _reminder {
            reminder.reapply()
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
