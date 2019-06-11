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

class ForecastService {
    
    static let shared = ForecastService()
    
    var sunsetTime: Date?
    var sunriseTime: Date?
    var currentUVIndex: Double?
    var currentCloudCoverage: Double?
    
    var fiveDayForecast: Array<DailyForecast> = Array()
    
    lazy var client: DarkSkyClient = {
        let darkSky = DarkSkyClient(apiKey: "16d1cdbf343ab6a7ee0dcb340b7484ff")
        darkSky.units = .auto
        darkSky.language = .english
        return darkSky
    }()
    
    private var isUpdating = false
    private var lastUpdate: Date?
    
    func updateUVIndexIfNeeded(_ location: CLLocation, completionHandler: ((Bool) ->())?) {
        guard !isUpdating else { return }
        
        if let lastUpdate = lastUpdate, Calendar.current.compare(Date(), to: lastUpdate, toGranularity: .hour).rawValue == 0 {
            // Updated in last hour, so bail
            return
        }
        
        isUpdating = true
        
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
                    self.sunsetTime = sunsetTime
                    ReminderService.shared.sunSet = sunsetTime
                }
                
                if let sunriseTime = result.value.0?.daily?.data[0].sunriseTime {
                    self.sunriseTime = sunriseTime
                    ReminderService.shared.sunRise = sunriseTime
                }
                
                var i = 0
                self.fiveDayForecast = Array()
                
                while i < 4 {
                    if let dailyData = result.value.0?.daily?.data[i]{
                        let dailyForecast = DailyForecast()
                        dailyForecast.forecastDate = dailyData.time
                        dailyForecast.cloudCoverage = dailyData.cloudCover
                        dailyForecast.uvIndex = dailyData.uvIndex
                        dailyForecast.sunriseTime = dailyData.sunriseTime ?? Date()
                        dailyForecast.sunsetTime = dailyData.sunsetTime ?? Date()
                        self.fiveDayForecast.append(dailyForecast)
                    }
                    i += 1
                }
                
                self.lastUpdate = Date()
                self.isUpdating = false
                if let completionHandler = completionHandler {
                    completionHandler(true)
                }
            }
        }
        
    }

    
}
