//
//  Reminder.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/11/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

enum SunscreenMethod {
    case spray
    case cream
}

enum ProtectionLevel {
    case normal
    case high
    case maximum
}

class Reminder {
    
    var protection: ProtectionLevel = .normal
    var method: SunscreenMethod = .spray
    
    var start: Date?
    var end: Date?
    
    var reapplys: Array<Date> = Array()
    
    var scheduledNotification: Date?
    
    public func updateScheduledNotification() {
        scheduledNotification = Date(timeIntervalSinceNow: TimeInterval(calculateSecondsToReapply()))
    }
    
    public func reapply() {
        reapplys.append(Date())
        updateScheduledNotification()
    }
    
    private func latestDateBeforeEnd() -> Date? {
        if reapplys.isEmpty {
            return start
        }
        else {
            return reapplys.last
        }
    }
    
    public func protectionLevel(for date: Date) -> Double {
        guard let start = start, let end = end,
            date >= start, date <= end else { return 0.0 }
        
        if let latestDate = latestDateBeforeEnd() {
            let seconds = Int(date.timeIntervalSince(latestDate))
            let maxSeconds = calculateSecondsToReapply()
            var protectionLevel = 100.0
            
            if seconds <= maxSeconds {
                return protectionLevel
            }
            
            // After max exposure, reduce by 1/2 every 2 hours
            var factor = Int(((seconds - maxSeconds) / 60) / 60 / 2)
            
            while (factor > 0) {
                protectionLevel /= 2.0
                factor -= 1
            }
            
            return protectionLevel
        }
        return 0.0
    }
    
    public func calculateSecondsToReapply() -> Int {
        
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
