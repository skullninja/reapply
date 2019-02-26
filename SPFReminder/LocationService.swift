//
//  LocationService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/25/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationService()
    
    let locationManager = CLLocationManager()
    
    func activateLocationServices() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        ForecastService.shared.updateUVIndexIfNeeded(locations[0], completionHandler: {_ in
           
            ReminderService.shared.location = locations[0]
           
        })
    }
    
}
