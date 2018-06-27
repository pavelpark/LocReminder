//
//  Extensions.swift
//  LocationReminders
//
//  Created by Rob Hatfield on 6/27/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let ReminderSaved = Notification.Name("ReminderSaved")
    static let ReminderCompleted = Notification.Name("ReminderCompleted")
}

extension UIColor {
    struct LRColor {
        static let enabledButtonColor = UIColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1)
        static let disabledButtonColor = UIColor.gray
        static let yellowNoteColor = UIColor(red: 0.999534, green: 0.988357, blue: 0.472736, alpha: 1)
        static let pinkNoteColor = UIColor(red: 0.939375, green: 0.703384, blue: 0.837451, alpha: 1)
    }
}
