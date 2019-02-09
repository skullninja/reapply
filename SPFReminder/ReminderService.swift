//
//  ReminderService.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/2/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import UserNotifications

enum SunscreenMethod {
    case spray
    case cream
}

enum ProtectionLevel {
    case normal
    case high
    case maximum
}

class ReminderService {
    
    static let shared = ReminderService()
    
    fileprivate var _timer: Timer?
    fileprivate var _isTimerRunning = false
    fileprivate var _nextReapplyDate: Date?
    
    //TODO: Watch for change
    var protection: ProtectionLevel = .normal
    var method: SunscreenMethod = .spray
    
    var sunDown: Date?
    var sunUp: Date?
    
    var isRunning: Bool {
        get {
            return _isTimerRunning
        }
    }
    
    var nextReapply: Date? {
        get {
            return _nextReapplyDate
        }
    }
    
    init() {
        
    }
    
    func start() {
        guard !isRunning else { return }
        let seconds = calculateSecondsToReapply()
        NotificationService.shared.setReminderNotification(seconds)
        _nextReapplyDate = Date(timeIntervalSinceNow: TimeInterval(seconds))
        runTimer()
    }
    
    func stop() {
        resetTimer()
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
        _nextReapplyDate = Date(timeIntervalSinceNow: TimeInterval(seconds))
        runTimer()
    }
    
    func runTimer(){
        guard _timer == nil || !_isTimerRunning else { return }
        _isTimerRunning = true
        _timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        //guard countdownSeconds != 0 else { return }
        //countdownSeconds -= 1
        //lblTimerCountdown.text = timeString(time: TimeInterval( self.countdownSeconds))
    }
    
    func resetTimer() {
        _timer?.invalidate()
        _isTimerRunning = false
        _nextReapplyDate = nil
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
        
        //reset timmer and remove any notifications
        resetTimer()
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
