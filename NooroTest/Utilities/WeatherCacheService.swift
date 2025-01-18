//
//  WeatherCacheService.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/17/25.
//

import Foundation

protocol WeatherCacheServiceable {
    func persist(weatherData: WeatherResponse)
    func loadCachedWeather() -> WeatherCache?
    func clearCache()
}

class WeatherCacheService: WeatherCacheServiceable {
    private let defaults = UserDefaults.standard
    private let cacheKey = "weather_cache_key"
    
    func persist(weatherData: WeatherResponse) {
        let weatherCache = WeatherCache(weatherResponse: weatherData)
        if let encoded = try? JSONEncoder().encode(weatherCache) {
            defaults.set(encoded, forKey: cacheKey)
        }
    }
    
    func loadCachedWeather() -> WeatherCache? {
        guard let data = defaults.data(forKey: cacheKey), let weatherCache = try? JSONDecoder().decode(WeatherCache.self, from: data) else {
            return nil
        }
        return weatherCache
    }
    
    func clearCache() {
        defaults.removeObject(forKey: cacheKey)
    }
}
