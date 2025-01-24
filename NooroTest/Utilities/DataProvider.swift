//
//  DataProvider.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/24/25.
//
import Foundation

protocol DataProvidable {
    func performQuery(with term: String) async throws -> Decodable
}

struct DataProvider: DataProvidable {
    private enum Constants {
        static let baseCurrentWeatherUrl = "https://api.weatherapi.com/v1/current.json"
        static let apiKey = "9222f99434ad4aa792a203504242201"
    }
    
    func performQuery(with term: String) async throws -> Decodable {
        guard var urlComponents = URLComponents(string: Constants.baseCurrentWeatherUrl) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: term),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        return response.statusCode == 200 ? try JSONDecoder().decode(WeatherResponse.self, from: data) : try JSONDecoder().decode(WeatherErrorResponse.self, from: data)
    }
}

