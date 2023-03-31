//
//  ForecastService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation
import CoreLocation
import WeatherKit

class ForecastService {
    
    static let shared = ForecastService()
    let weatherService = WeatherService()
    
    var sunsetTime: Date?
    var sunriseTime: Date?
    var currentUVIndex: Double?
    var maxUVIndex: Double?
    var currentCloudCoverage: Double?
    
    var fiveDayForecast: Array<DailyForecast> = Array()
    
    private var isUpdating = false
    private var lastUpdate: Date?
    private var updateAttemptCount = 0
    
    func updateUVIndexFromWKIfNeeded(for location: CLLocation, completion: @escaping (Bool) -> ()) async {
        self.updateAttemptCount += 1
        print("WeatherService Update Check: \(updateAttemptCount)")
        // Perform your guard and time check here
        guard !isUpdating else { return }
        
        if let lastUpdate = lastUpdate, Calendar.current.compare(Date(), to: lastUpdate, toGranularity: .hour).rawValue == 0 {
            // Updated in last hour, so bail
            print("WeatherService was recently fetched, so no new attempt will be made.")
            return
        }
        
        isUpdating = true
        print("WeatherService data is being fetched.")
        
        var weatherData: (current: CurrentWeather?, daily: Forecast<DayWeather>?)
        
        do {
            weatherData = try await self.weatherService.weather(for: location,
                                                                including: .current, .daily)
        } catch let error {
            print("Error fetching Weather: \(error)")
            self.isUpdating = false
            completion(false)
            return
        }
        
        
        if let weather = weatherData.current, let daily = weatherData.daily {
            
            // Extract current UV index
            self.currentUVIndex = Double(weather.uvIndex.value)
            self.currentCloudCoverage = weather.cloudCover
            
            // Extract maximum UV index for the day, sunrise and sunset time
            if let todayForecast = daily.first {
                self.maxUVIndex = Double(todayForecast.uvIndex.value)
                self.sunriseTime = todayForecast.sun.sunrise
                self.sunsetTime = todayForecast.sun.sunset
            }
            
            // Extract five-day forecast
            self.fiveDayForecast = daily.map { dailyWeather -> DailyForecast in
                let dailyForecast = DailyForecast()
                dailyForecast.forecastDate = dailyWeather.date
                dailyForecast.cloudCoverage = 0
                dailyForecast.uvIndex = Double(dailyWeather.uvIndex.value)
                if let sunsetTime = dailyWeather.sun.sunset {
                    dailyForecast.sunsetTime = sunsetTime
                }
                if let sunriseTime = dailyWeather.sun.sunrise {
                    dailyForecast.sunriseTime = sunriseTime
                }
                return dailyForecast
            }
            
            self.lastUpdate = Date()
            self.isUpdating = false
            completion(true)
        } else {
            print("Failed to fetch weather data")
            self.isUpdating = false
            completion(false)
        }
    }

    /*
    
    func updateUVIndexFromWeatherKitIfNeeded(_ location: CLLocation, completionHandler: ((Bool) ->())?) {
        guard !isUpdating else { return }
        
        if let lastUpdate = lastUpdate, Calendar.current.compare(Date(), to: lastUpdate, toGranularity: .hour).rawValue == 0 {
            // Updated in last hour, so bail
            return
        }
        
        isUpdating = true
        
        //TODO: Update When Day Switches or Location Changes
        //WeatherService.shared.weather(for: location, including: currentUVIndex)
        /*
        WeatherKit.shared.getUVIndex(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { (uvIndex, error) in
            DispatchQueue.main.async {
                if let error = error {
                    isUpdating = false
                    return
                }
                
                self.currentUVIndex = uvIndex.value
                
                //self.maxUVIndex = self.currentUVIndex
                //self.currentCloudCoverage = 0
                //self.sunsetTime =
                //self.sunriseTime =
                //self.fiveDayForecast
                
                self.lastUpdate = Date()
                self.isUpdating = false
                if let completionHandler = completionHandler {
                    completionHandler(true)
                }
            }
        }
         */
    }
    */
    /*
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
                
                if let maxUVIndex = result.value.0?.daily?.data[0].uvIndex {
                    self.maxUVIndex = maxUVIndex
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
*/
    
}
