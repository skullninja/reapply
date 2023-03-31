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
           startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        Task {
            await ForecastService.shared.updateUVIndexFromWKIfNeeded(for: locations[0], completion: {_ in
                ReminderService.shared.location = locations[0]
            })
        }
    }
    
    func restartUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            startUpdatingLocation()
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 11.0  // 7 miles
        locationManager.startUpdatingLocation()
    }

    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    
}
