//
//  ForecastService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import ForecastIO
import CoreLocation

class ForecastService{
    
    static let shared = ForecastService()
    
    var sunsetLocalTime = Date()
    var sunriseLocalTime = Date()
    var currentUVIndex:Double?
    var currentCloudCoverage:Double?
    
    lazy var client: DarkSkyClient = {
        let darkSky = DarkSkyClient(apiKey: "16d1cdbf343ab6a7ee0dcb340b7484ff")
        darkSky.units = .auto
        darkSky.language = .english
        return darkSky
    }()
    
    func updateUVIndexIfNeeded(_ location: CLLocation, completionHandler: @escaping (Bool) ->()) {
        
        //TODO: Update When Day Switches or Location Changes
        client.getForecast(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
            DispatchQueue.main.async {
                if let uvindex = result.value.0?.currently?.uvIndex {
                    self.currentUVIndex = uvindex
                }
                
                if let cloudCoverage = result.value.0?.currently?.cloudCover {
                    self.currentCloudCoverage = cloudCoverage
                }
                
                if let sunsetTime = result.value.0?.daily?.data[0].sunsetTime {
                    self.sunsetLocalTime = sunsetTime.convertFromGMT(timeZone: TimeZone.current)
                    ReminderService.shared.sunSet = self.sunsetLocalTime
                }
                
                if let sunriseTime = result.value.0?.daily?.data[0].sunriseTime {
                    self.sunriseLocalTime = sunriseTime.convertFromGMT(timeZone: TimeZone.current)
                    ReminderService.shared.sunRise = self.sunriseLocalTime
                }
                
                completionHandler(true)
            }
        }
        
    }

    
}
