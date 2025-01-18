//
//  WeatherCache.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/17/25.
//

import Foundation

struct WeatherCache: Codable {
    let locationName: String
    let celsiusDegrees: Int
    let humidity: Int
    let uv: Int
    let feelsLikeCelsius: Int
    let iconUrl: String
    let timestamp: Double
    
    init(weatherResponse: WeatherResponse) {
        self.locationName = weatherResponse.location?.name ?? ""
        self.celsiusDegrees = Int(weatherResponse.current?.celsiusDegrees ?? 0)
        self.humidity = Int(weatherResponse.current?.humidity ?? 0)
        self.uv = Int(weatherResponse.current?.uv ?? 0)
        self.feelsLikeCelsius = Int(weatherResponse.current?.feelsLikeCelsius ?? 0)
        self.iconUrl = weatherResponse.current?.condition?.iconUrl ?? ""
        self.timestamp = Date().timeIntervalSince1970 // Perhaps we need to invalidate after some period?
    }
}
