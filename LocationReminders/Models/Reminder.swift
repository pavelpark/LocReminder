//
//  Reminder.swift
//  LocationReminders
//
//  Created by Rob Hatfield on 2/14/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//

import Foundation
import CoreLocation

struct Reminder {
    var name: String
    var region: CLCircularRegion
    
    enum CodingKeys: String, CodingKey {
        case name = "reminderName"
        case centerLatitude
        case centerLongitude
        case radius
        case identifier
    }
}

extension Reminder: Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let latitude = try values.decode(Double.self, forKey: .centerLatitude)
        let longitude = try values.decode(Double.self, forKey: .centerLongitude)
        let radius = try values.decode(Double.self, forKey: .radius)
        let identifier = try values.decode(String.self, forKey: .identifier)
        region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                  radius: radius,
                                  identifier: identifier)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(region.center.latitude, forKey: .centerLatitude)
        try container.encode(region.center.longitude, forKey: .centerLongitude)
        try container.encode(region.radius, forKey: .radius)
        try container.encode(region.identifier, forKey: .identifier)
    }
    
    /* MARK: TODO: Add a class for loading and saving to disk.
     We'll probably use something similar to this:
        https://medium.com/@sdrzn/swift-4-codable-lets-make-things-even-easier-c793b6cf29e1
     His Disk framework is probably more than we'll need.
     */
}
