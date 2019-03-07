//
//  ReminderService.swift
//  SPFReminder
//
//  Created by Dave Peck on 2/2/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
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
    //to do: remove after testing
    var locationUpdateTime: Date?
    
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
            
            #if DEBUG
            #else
            if currentDate > sunDown { return .tooLate }
            #endif
            
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
    
        //saves reminder to cloudkit
        if CloudKitManager.shared.hasAccount{
            ReminderModel.shared.add(reminder: reminder)
        }
        //saves reminder to disk
        save(reminder)
        
        return .started
    }
    
    func stop() {
        if let reminder = _reminder {
            reminder.end = Date()
            save(reminder)
        }
        _reminder = nil
        print("notifications removed")
        NotificationService.shared.removeNotifications()
    }
    
    func reapply() {
        guard isRunning else { return }
        if let reminder = _reminder {
            reminder.reapply()
            NotificationService.shared.setReminderNotification(reminder)
            save(reminder)
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
    
}

extension ReminderService {
    
    func save(_ reminder: Reminder) {
        guard let start = reminder.start else { return }
        
        let pathDirectory = getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent(start.toString(dateFormat: "yyyy-MM-dd-HH-mm-ss") + ".json")
        
        let json = try? JSONEncoder().encode(reminder)
        
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    func loadAll() -> [Reminder] {
        let pathDirectory = getDocumentsDirectory()
        let filenames = try? FileManager().contentsOfDirectory(at: pathDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        var reminders: [Reminder] = []
        
        if let filenames = filenames {
            for fn in filenames {
                if let data = FileManager().contents(atPath: fn.absoluteString),
                    let reminder = try? JSONDecoder().decode(Reminder.self, from: data) {
                    reminders.append(reminder)
                }
            }
        }
        
        return reminders
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0].appendingPathComponent("reminders")
    }
}
