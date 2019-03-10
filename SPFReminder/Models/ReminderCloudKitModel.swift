//
//  ReminderModel.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 3/5/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import CloudKit

class ReminderCloudKitModel{
    
    static let shared = ReminderCloudKitModel()
    
    private let database = CKContainer.default().privateCloudDatabase
    
    func add(reminder: Reminder){
    
        if let json = try? JSONEncoder().encode(reminder),
            let content = String(data: json, encoding: .utf8),
            let start = reminder.start {
            let reminderRecord = CKRecord(recordType: "Reminder")
            reminderRecord.setValue(content, forKey: "content")
            reminderRecord.setValue(start, forKey: "start")
            
            database.save(reminderRecord) { _, error in
                guard error != nil else { return }
                print("error: \(String(describing: error))")
            }
 
        }
    }
    
    func fetchReminders(_ resultsLimit: Int) -> [Reminder]{
        
        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "Reminder", predicate: pred)
        //query.sortDescriptors = [NSSortDescriptor(key: "start", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["content", "start"]
        operation.resultsLimit = resultsLimit
        
        var newReminders = [Reminder]()
        
        operation.recordFetchedBlock = { record in
            if  let content = record.value(forKey: "content") as? String,
                let data = content.data(using: .utf8),
                let reminder = try? JSONDecoder().decode(Reminder.self, from: data) {
                
                newReminders.append(reminder)
            }
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                  print("no error")
                } else {
                    print("Fetch failed. There was a problem fetching the list of reminders: \(error!.localizedDescription)")
                }
            }
        }
        database.add(operation)
        
        return newReminders
    }
    
    func syncReminders() {
        
        var localReminders: [Reminder] = ReminderService.shared.loadAll()
        var cloudKitReminders: [Reminder] = fetchReminders(50)
        
        //no reminders saved on the device. save any reminders from cloudkit to device.
        if localReminders.count == 0 {
            for reminder in cloudKitReminders{
                ReminderService.shared.save(reminder)
            }
            return
        }
        
        //check if any reminder exist on the device and not in cloudkit
        if localReminders.count > 0 {
            
            localReminders.sort(by: { $0.start!.compare($1.start!) == .orderedDescending
            })
            
            cloudKitReminders.sort(by: { $0.start!.compare($1.start!) == .orderedDescending
            })
            
             for reminder in localReminders{
                print(reminder.start ?? Date())
            }
           
        }
        
    }
}
