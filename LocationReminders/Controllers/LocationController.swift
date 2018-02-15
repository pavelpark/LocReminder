//
//  LocationController.swift
//  LocationReminders
//
//  Created by Rob Hatfield on 2/14/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//

import Foundation
import MapKit
import UserNotifications

protocol LocationControllerDelegate {
    func locationControllerUpdatedLocation(_: CLLocation) -> ()
}

class LocationController: NSObject {
    // MARK: Properties
    let locationManager = CLLocationManager()
    var location = CLLocation()
    var delegate: LocationControllerDelegate?
    var allRegions = [CLCircularRegion]()
    
    // MARK: Singleton pattern
    static let sharedInstance = LocationController()
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: Public methods
    func requestPermissions() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func monitorSignificantMovements() {
        // Update only every 5 km while in background
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = 5000
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func monitorFullMovements() {
        // Continual updates when more accuracy is needed
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func addRegion(_ region: CLCircularRegion) {
        allRegions.append(region)
        print("All regions: \n-===-\n%@", allRegions)
    }
    
    func checkForNearbyRegions() {
        var nearbyRegions = [CLCircularRegion]()
        
        for region in allRegions {
            let regionCenterLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            if regionCenterLocation.distance(from: self.location) < 10000 {
                nearbyRegions.append(region)
            }
        }
    }
    
    func startMonitoringForRegion(_ region: CLRegion) {
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoringForRegionWithIdentifier(_ regionIdentifier: String) {
        let filteredRegions = locationManager.monitoredRegions.filter { $0.identifier == regionIdentifier }
        guard let regionToRemove = filteredRegions.first else {
            print("No matching region found to remove from monitoring")
            return
        }
        print("Removing region %@", regionToRemove)
        locationManager.stopMonitoring(for: regionToRemove)
    }
    
    func resetMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        allRegions.removeAll()
    }
    
    func postNotificationForReminderNamed(_ name: String, withId objectId: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = name
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "REMINDER"
        content.userInfo = ["objectId": objectId]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "Location Entered", content: content, trigger: trigger)
        let currentNC = UNUserNotificationCenter.current()
        currentNC.removeAllPendingNotificationRequests()
        currentNC.add(request) { (error) in
            if (error != nil) {
                print("Error posting user notification: %@", error?.localizedDescription as Any)
            }
        }
    }
}

extension LocationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        location = lastLocation
        delegate?.locationControllerUpdatedLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Starting monitoring for region: %@", region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered region: %@", region.identifier)
        postNotificationForReminderNamed(region.identifier, withId: region.identifier)
    }
}
