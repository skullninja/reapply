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
        
        let reminderRecord = CKRecord(recordType: "Reminder")
        reminderRecord.setObject(reminder.start! as __CKRecordObjCValue, forKey: "start")
        reminderRecord.setObject(reminder.end! as __CKRecordObjCValue, forKey: "end")
        reminderRecord.setObject(reminder.scheduledNotification! as __CKRecordObjCValue, forKey: "scheduledNotification")
        
        if reminder.method == SunscreenMethod.cream{
            reminderRecord.setObject(1.0 as __CKRecordObjCValue, forKey: "sunscreenMethod")
        }else{
            reminderRecord.setObject(0.0 as __CKRecordObjCValue, forKey: "sunscreenMethod")
        }
        
        if reminder.protection == ProtectionLevel.normal{
            reminderRecord.setObject(0.0 as __CKRecordObjCValue, forKey: "protectionLevel")
        }else if reminder.protection == ProtectionLevel.high{
            reminderRecord.setObject(5.0 as __CKRecordObjCValue, forKey: "protectionLevel")
        }else{
            reminderRecord.setObject(10.0 as __CKRecordObjCValue, forKey: "protectionLevel")
        }
        
        database.save(reminderRecord) { _, error in
            guard error == nil else {
               
                return
            }
        }
    }
    
    func fetchReminders(){
        
        //let query = CKQuery(recordType: "Reminder", predicate: NSPredicate(value: true))
        
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "start", ascending: false)
        let query = CKQuery(recordType: "Reminder", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["scheduledNotification"]
        operation.resultsLimit = 20
        
        var newReminders = [Reminder]()
        
        operation.recordFetchedBlock = { record in
            let reminder = Reminder()
            reminder.start = record["start"]
            reminder.scheduledNotification = record["scheduledNotification"]
            newReminders.append(reminder)
        }
        
        /*
        database.perform(query, inZoneWith: nil) { (records, error) in
            records?.forEach({ (record) in
                
                // System Field from property
                let recordName_fromProperty = record.recordID.recordName
                print("System Field, recordName: \(recordName_fromProperty)")
                
                // Custom Field from key path (eg: deeplink)
                let scheduledNotification = record.value(forKey: "scheduledNotification")
                print("Custom Field, scheduledNotification: \(scheduledNotification ?? "")")
            })

            
        }
  */
    }
}
