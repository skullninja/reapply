//
//  Reminder.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/11/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import CoreLocation

enum SunscreenMethod: String, Codable {
    case spray = "spray"
    case cream = "cream"
}

enum ProtectionLevel: String, Codable {
    case normal = "normal"
    case high = "high"
    case maximum = "maximum"
}

class Reminder: Codable {
    
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
    
    private func latestDateBeforeDate(_ date: Date) -> Date? {
        if reapplys.isEmpty {
            return start
        }
        else {
            var latest = start
            for reapplyDate in reapplys {
                if reapplyDate < date {
                    latest = reapplyDate
                }
            }
            return latest
        }
    }
    
    public func dataPoints() -> Array<Double> {
        
        var dataPoints = Array<Double>()
        
        if let end = end, let start = start {
            let seconds = end.timeIntervalSince(start)
            let hours = Int(seconds / 60 / 60)
            var check = 0
            
            while (check <= hours) {
                if let interval = TimeInterval(exactly: 60 * 60 * check) {
                    let time = start.addingTimeInterval(interval)
                    dataPoints.append(protectionLevel(for: time))
                }
                check += 1
            }
        }
        
        return dataPoints
    }
    
    public func protectionLevel(for date: Date) -> Double {
        guard let start = start, let end = end,
            date >= start, date <= end else { return 0.0 }
        
        if let latestDate = latestDateBeforeDate(date) {
            let seconds = Int(date.timeIntervalSince(latestDate))
            let maxSeconds = calculateSecondsToReapply()
            var protectionLevel = 100.0
            
            if seconds <= maxSeconds {
                return protectionLevel
            }
            
            // After max exposure, reduce by 1/2 every 2 hours
            let hours = Int(((seconds - maxSeconds) / 60) / 60)
            var count = 0
            var factor = protectionLevel
            while count < hours {
                protectionLevel -= (factor * 0.25)
                if count % 2 == 1 {
                    factor = factor / 2.0
                }
                count += 1
            }
            
            return max(protectionLevel, 0.0)
        }
        return 0.0
    }
    
    public func calculateSecondsToReapply() -> Int {
        
        var seconds = 7200
        
        switch protection {
        case .normal:
            break
        case .high:
            seconds = 4800
            break
        case .maximum:
            seconds = 2400
            break
        }
        
        return seconds
        
    }
}
