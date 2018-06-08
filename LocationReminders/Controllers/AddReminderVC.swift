//
//  AddReminderVC.swift
//  LocationReminders
//
//  Created by Rob Hatfield on 2/14/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//

import UIKit
import MapKit

typealias NewReminderCreateCompletion = (MKCircle) -> ()

extension UIColor {
    struct LRColor {
        static let enabledButtonColor = UIColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1)
        static let disabledButtonColor = UIColor.gray
        static let yellowNoteColor = UIColor(red: 0.999534, green: 0.988357, blue: 0.472736, alpha: 1)
        static let pinkNoteColor = UIColor(red: 0.939375, green: 0.703384, blue: 0.837451, alpha: 1)
    }
}

class AddReminderVC: UIViewController {
    
    @IBOutlet weak var locationRadius: UITextField!
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var radiusUnits: UISegmentedControl!
    @IBOutlet weak var setReminderButton: UIButton!
    @IBOutlet weak var nameNoteLabel: UILabel!
    @IBOutlet weak var radiusNoteLabel: UILabel!
    @IBOutlet weak var nameWarning: UILabel!
    @IBOutlet weak var radiusWarning: UILabel!
    
    var annotationTitle: String = ""
    var coordinate = CLLocationCoordinate2D()
    var completion: NewReminderCreateCompletion?
    
    var userUnits: Int = 0
    var radiusMeasurement = Measurement(value: 15.0, unit: UnitLength.meters)
    // Radius must be 15m - 40km.
    let minRadius = 15, /* 15 m. / ~50 ft. */  maxRadius = 40234 // ~40 km. / 25 mi.
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: TODO: Set delegates for textfields (locationName & locationRadius)
        // locationName.delegate = self
        // locationRadius.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(validateReminder), name: .UITextFieldTextDidChange, object: self.locationRadius)
        NotificationCenter.default.addObserver(self, selector: #selector(validateReminder), name: .UITextFieldTextDidChange, object: self.locationName)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UserDefault value evaluates to 0 (meters) if not already set
        self.userUnits = UserDefaults.standard.integer(forKey: "userUnits")
        print("User units set to %d", self.userUnits)
        radiusUnits.selectedSegmentIndex = userUnits
        updateUnits()
        setupView()
    }
    
    func updateUnits() {
        switch userUnits {
        case 0:
            // Meters
            locationRadius.placeholder = "Distance in meters"
            radiusNoteLabel.text = "From 15 to 40,000 m"
            radiusMeasurement.convert(to: .meters)
            self.locationRadius.keyboardType = .numberPad
            break
        case 1:
            // Kilometers
            locationRadius.placeholder = "Distance in kilometers"
            radiusNoteLabel.text = "From 0.1 to 40 km"
            radiusMeasurement.convert(to: .kilometers)
            self.locationRadius.keyboardType = .decimalPad
            break
        case 2:
            // Feet
            locationRadius.placeholder = "Distance in feet"
            radiusNoteLabel.text = "From 50 to 132,000 ft"
            radiusMeasurement.convert(to: .feet)
            locationRadius.keyboardType = .numberPad
            break
        case 3:
            // Miles
            locationRadius.placeholder = "Distance in miles"
            radiusNoteLabel.text = "From 0.01 to 25 mi"
            radiusMeasurement.convert(to: .miles)
            locationRadius.keyboardType = .decimalPad
            break
        default:
            break
        }
        
        if locationRadius.isFirstResponder {
            locationRadius.reloadInputViews()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkRegionLimits()
    }
    
    func setupView() {
        setReminderButton.backgroundColor = UIColor.LRColor.disabledButtonColor
        setReminderButton.layer.cornerRadius = 5.0
        setReminderButton.clipsToBounds = true
        radiusNoteLabel.layer.cornerRadius = 2.5
        radiusNoteLabel.clipsToBounds = true
        nameNoteLabel.layer.cornerRadius = 2.5
        nameNoteLabel.clipsToBounds = true
    }
    
    func checkRegionLimits() {
        // Check how many regions are currently being monitored.
        let monitoredRegionCount = LocationController.sharedInstance.locationManager.monitoredRegions.count
        let regionLimit = 20
        let regionWarningCount = 17
        if monitoredRegionCount < regionWarningCount {
            return
        }
        
        // Determine the appropriate warning for user.
        let remainingRegions = regionLimit - monitoredRegionCount
        let warningMessage: String
        switch remainingRegions {
        case 0:
            print("Monitored regions is full!")
            warningMessage = "You can create this reminder, but you will not be alerted of it until you complete some of your previous reminders."
        case 1:
            print("Last region to be monitored.")
            warningMessage = "This is the last reminder we can actively monitor. Complete reminders to free up space."
        default:
            warningMessage = "We can only monitor \(regionLimit) reminders at a time. You are approaching your limit; there are \(remainingRegions) reminders remaining."
        }
        
        // Present an alert to the user.
        let regionLimitAlertController = UIAlertController(title: "LocReminder Warning", message: warningMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        regionLimitAlertController.addAction(okAction)
        self.present(regionLimitAlertController, animated: true, completion: nil)
    }
    
    func validateReminder(sender: NSNotification) {
        var validName = true, validRadius = true
        
        if locationName.text == "" {
            validName = false
            nameNoteLabel.textColor = UIColor.white
            nameNoteLabel.backgroundColor = UIColor.LRColor.pinkNoteColor
            nameWarning.isHidden = false
        } else {
            nameNoteLabel.textColor = UIColor.darkGray
            nameNoteLabel.backgroundColor = UIColor.LRColor.yellowNoteColor
            nameWarning.isHidden = true
        }
        
        let regex = "(^[^\\D]{0,4}(\\.?)\\d{0,3}$)" // Permits 0-4 digits before an optional decimal point, and 0-3 digits after. I.e., 0.001 to 9999.999 is allowed.
        let matchedRange = locationRadius.text?.range(of: regex, options: .regularExpression)
        let radiusText = locationRadius.text ?? ""
        let unwrappedRadius = Float(radiusText) ?? 0.0
        if matchedRange == nil || unwrappedRadius == 0.0 {
            validRadius = false
        }
        
        //MARK: TODO: Finish converting validateReminder function from Obj-C
    }

}

extension AddReminderVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationName.resignFirstResponder()
        locationRadius.resignFirstResponder()
        return true
    }
}
