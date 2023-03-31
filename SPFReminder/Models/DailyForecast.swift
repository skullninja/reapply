//
//  DailyForecast.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 2/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

class DailyForecast {
    
    var forecastDate = Date()
    var sunsetTime = Date()
    var sunriseTime = Date()
    var uvIndex:Double?
    
    @available(*, deprecated, message: "Not available in WeatherKit")
    var cloudCoverage:Double?
    
    var ForecastSummary:String?
    
}
