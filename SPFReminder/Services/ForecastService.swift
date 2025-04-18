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
}
