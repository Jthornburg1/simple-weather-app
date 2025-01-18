//
//  WeatherResponse.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/15/25.
//

struct WeatherResponse: Decodable, Equatable {
    let location: SearchLocation?
    let current: CurrentWeather?
}

struct SearchLocation: Decodable, Equatable {
    let name: String?
}

struct CurrentWeather: Decodable, Equatable {
    let celsiusDegrees: Double?
    let condition: WeatherCondition?
    let humidity: Double?
    let uv: Double?
    let feelsLikeCelsius: Double?
    
    enum CodingKeys: String, CodingKey {
        case celsiusDegrees = "temp_c"
        case condition
        case humidity
        case uv
        case feelsLikeCelsius = "feelslike_c"
    }
}

struct WeatherCondition: Decodable, Equatable {
    let iconUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case iconUrl = "icon"
    }
}

struct WeatherErrorResponse: Decodable {
    let error: WeatherErrorBody?
}

struct WeatherErrorBody: Decodable {
    let message: String?
    let code: Double?
}
