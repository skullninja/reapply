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
    
    var scheduledNotification: Date?
    
}
