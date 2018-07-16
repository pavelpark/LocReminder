//
//  CloudKit.swift
//  LocationReminders
//
//  Created by Pavel Parkhomey on 6/26/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//

import Foundation
import CloudKit

typealias SuccessCompletion = (Bool) -> ()
typealias ReminderCompletion = ([Reminder]?)->()

class CloudKit {
    //creating a CloudKit as a singleton
    static let shared = CloudKit()
    private init ( ){ }
    //creating a container to store later
    let container = CKContainer.default()
    
    var privateDatabase : CKDatabase {
        return container.privateCloudDatabase
    }
    
    func save(reminder: Reminder, completion: @escaping SuccessCompletion) {
        let record = recordForReminder(reminder)
        privateDatabase.save(record, completionHandler: { (record, error) in
            
            if error != nil {
                completion(false)
                return
            }
            if let record = record {
                print(record)
                completion(true)
            } else {
                completion(false)
                
            }
        })
    }
    
    func getReminders(completion: @escaping ReminderCompletion) {
        
        let reminderQuery = CKQuery(recordType: "Reminder", predicate: NSPredicate(value: true))
        
        self.privateDatabase.perform(reminderQuery, inZoneWith: nil) { (records, error) in
            
            if error != nil {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
            
            if let records = records {
                
                var reminders = [Reminder]()
                
                for record in records {
                    if let name = record["name"] as? String, let region = record["region"] as? CLCircularRegion {
                        let reminder = Reminder(name: name, region: region)
                        reminders.append(reminder)
                    } else {
                        print("coudn't unwrap the reminder \(record)")
                    }
                }
                    OperationQueue.main.addOperation {
                    completion(reminders)
                }
            }
        }
    }
    
    func recordForReminder(_ reminder: Reminder) -> CKRecord {
        let record = CKRecord(recordType: "Reminder")
        record.setValue(reminder.name, forKey: "name")
        record.setValue(reminder.region, forKey: "region")
        return record
    }
}

