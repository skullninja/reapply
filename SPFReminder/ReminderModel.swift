//
//  ReminderModel.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 3/5/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import CloudKit

class ReminderModel{
    
    static let shared = ReminderModel()
    
    private let database = CKContainer.default().privateCloudDatabase
    
    private let cloudKitManager = CloudKitManager()
    
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
    
    func fetchReminders(){
        
        //let query = CKQuery(recordType: "Reminder", predicate: NSPredicate(value: true))
        
        let pred = NSPredicate(value: true)
        //let sort = NSSortDescriptor(key: "start", ascending: false)
        let query = CKQuery(recordType: "Reminder", predicate: pred)
       // query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["content", "start"]
        operation.resultsLimit = 20
        
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
    }
}
