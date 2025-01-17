//
//  WeatherViewModel.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/15/25.
//

import SwiftUI

extension WeatherView {
    
    class ViewModel: ObservableObject {
        @Published var searchTerm: String = ""
        @Published var isLoading = false
        @Published var weatherResponse: WeatherResponse?
        @Published var weatherFetchError: WeatherErrorResponse?
        @Published var isOtherApiError = false
        @Published var weatherImage: Image?
        
        private let baseCurrentWeatherUrl = "https://api.weatherapi.com/v1/current.json"
        private let apiKey = "9222f99434ad4aa792a203504242201"
        private let urlSchemePrefix = "https:"
        
        nonisolated func performSearch() async throws -> Decodable {
            guard var urlComponents = URLComponents(string: baseCurrentWeatherUrl) else {
                throw URLError(.badURL)
            }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: searchTerm),
                URLQueryItem(name: "key", value: apiKey)
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
        
        @MainActor
        func updateValues() {
            Task {
                setIsLoading(true)
                do {
                    let fetched = try await performSearch()
                    await MainActor.run {
                        if let weather = fetched as? WeatherResponse {
                            self.weatherResponse = weather
                            self.setWeatherImage()
                        } else if let weatherError = fetched as? WeatherErrorResponse {
                            setIsLoading(false)
                            self.weatherFetchError = weatherError
                        }
                    }
                } catch {
                    setIsLoading(false)
                    await MainActor.run {
                        self.isOtherApiError = true
                    }
                }
            }
        }
        
        @MainActor
        private func setIsLoading(_ loading: Bool) {
            self.isLoading = loading
        }
        
        nonisolated private func fetchImage() async throws -> Image? {
            guard let iconUrlString = self.weatherResponse?.current?.condition?.iconUrl, let iconUrl = URL(string: "https:\(iconUrlString)") else {
                throw URLError(.badURL)
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: iconUrl)
                if let uiImage = UIImage(data: data) {
                    return Image(uiImage: uiImage)
                }
            } catch {
                throw URLError(.badServerResponse)
            }
            return nil
        }
        
        @MainActor
        private func setWeatherImage() {
            Task {
                do {
                    let image = try await fetchImage()
                    setIsLoading(false)
                    await MainActor.run {
                        self.weatherImage = image
                    }
                } catch {
                    // Errors have been thrown, use placeholder
                    await MainActor.run {
                        self.weatherImage = Image(systemName: "questionmark.circle.fill")
                    }
                }
            }
        }
    }
}
