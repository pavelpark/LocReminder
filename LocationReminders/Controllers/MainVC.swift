//
//  MainVC.swift
//  LocationReminders
//
//  Created by Rob Hatfield on 2/14/18.
//  Copyright © 2018 Pavel Parkhomey. All rights reserved.
//

import UIKit
import MapKit

class MainVC: UIViewController {

    // MARK: Outlets & properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
//    var locationController: LocationController
    var mapShouldFollowUser: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let annotationView = sender as? MKAnnotationView, segue.identifier == "AddReminderViewController" else {
            return
        }
        let newReminderVC = segue.destination
        // MARK: TODO
        // Finish duplicating this logic. But first we need a Swift version of the AddReminderVC.
    }


}
