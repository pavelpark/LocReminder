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
    let identifier: UUID
    var region: CLCircularRegion
}
