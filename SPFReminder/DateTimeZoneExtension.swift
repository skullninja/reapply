//
//  DateTimeZoneExtension.swift
//  SPFReminder
//
//  Created by Dave Peck on 1/31/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

extension Date {

    func convertFromGMT(timeZone: TimeZone) -> Date {
        let delta = TimeInterval(timeZone.secondsFromGMT())
        return addingTimeInterval(delta)
    }

    func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
        let delta = TimeInterval(timeZone.secondsFromGMT() - initTimeZone.secondsFromGMT())
        return addingTimeInterval(delta)
    }
    
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}
