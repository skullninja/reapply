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
