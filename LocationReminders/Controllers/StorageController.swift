//
//  StorageController.swift
//  LocationReminders
//
//  Created by Pavel Parkhomey on 6/28/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//
//  Based off of storage by Saoud M. Rizwan:
//  https://medium.com/@sdrzn/swift-4-codable-lets-make-things-even-easier-c793b6cf29e1

import Foundation

public class StorageController {
    fileprivate init() { }
    
    static var allReminders = [Reminder]()
    
    static fileprivate func getURL() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for directory!")
        }
    }
    
    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - fileName: what to name the file where the struct data will be stored
    static fileprivate func store<T: Encodable>(_ object: T, as fileName: String) {
        let url = getURL()
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static fileprivate func retrieve<T: Decodable>(_ fileName: String, as type: T.Type) -> T {
        let url = getURL()
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File at path \(url.path) does not exist.")
        }
        if let data = FileManager.default.contents(atPath: url.path){
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)")
        }
    }
    
    /// Remove all files for this app
    static func clearReminders() {
        let url = getURL()
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileURL in contents {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Save a new reminder to disk
    /// - Parameters:
    ///   - _ reminder: A Reminder object
    static func save(_ reminder: Reminder) {
        allReminders.append(reminder)
        store(allReminders, as: "Reminders")
    }
    
    /// Load reminders from disk
    /// - Returns: An array of Reminders
    static func loadReminders() -> [Reminder] {
        let reminders = retrieve("Reminders", as: [Reminder].self)
        return reminders
    }
}
