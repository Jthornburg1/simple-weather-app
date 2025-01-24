//
//  WeatherViewModel.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/15/25.
//

import SwiftUI

extension WeatherView {
    class ViewModel: ObservableObject {
        @Published var queryTerm: String = ""
        @Published var isLoading = false
        @Published var weatherCache: WeatherCache?
        @Published var weatherFetchError: WeatherErrorResponse?
        @Published var isOtherApiError = false
        @Published var viewState: WeatherViewState = .initial
        
        let cacheService: WeatherCacheServiceable
        let dataProvider: DataProvidable
        
        private var queryTask: Task<Void, Never>?
        
        init(cacheService: WeatherCacheServiceable = WeatherCacheService(), dataProvider: DataProvidable = DataProvider()) {
            self.cacheService = cacheService
            self.weatherCache = cacheService.loadCachedWeather()
            self.dataProvider = dataProvider
        }
        
        @MainActor
        func handleViewState() {
            if self.isLoading {
                viewState = .loading
            } else if self.weatherFetchError != nil {
                self.handleWeatherFetchError(self.weatherFetchError?.error?.code ?? 0)
            } else if self.isOtherApiError {
                viewState = .error("Something went wrong on our side. Please try another search.")
            } else {
                viewState = .loaded
            }
        }
        
        @MainActor
        func determineInitialState() {
            self.viewState = self.weatherCache == nil ? .initial : .detailed
        }
        
        @MainActor
        private func handleWeatherFetchError(_ code: Double) {
            switch code {
            case 1003:
                self.viewState = .error("You must provide a location to search view weather.")
            case 1006:
                self.viewState = .error("The search term you entered didn't match a location in our records.")
            default:
                self.viewState = .error("There was an error on our side. Please try again.")
            }
        }
        
        @MainActor
        func expandToDetailView() {
            if self.weatherCache != nil {
                self.viewState = .detailed
            }
        }
        
        @MainActor
        func updateValues() {
            self.weatherFetchError = nil
            queryTask?.cancel()
            self.queryTask = Task {
                self.setIsLoading(true)
                self.handleViewState()
                defer {
                    self.setIsLoading(false)
                    self.handleViewState()
                }
                do {
                    let fetched = try await dataProvider.performQuery(with: self.queryTerm)
                    self.handleFetch(fetched)
                } catch {
                    self.handleFetchError()
                }
            }
        }
        
        @MainActor
        private func handleFetch(_ result: Decodable) {
            if let weather = result as? WeatherResponse {
                self.cacheService.persist(weatherData: weather)
                self.weatherCache = cacheService.loadCachedWeather()
                self.queryTerm = ""
            } else if let weatherError = result as? WeatherErrorResponse {
                self.weatherCache = nil
                self.weatherFetchError = weatherError
            }
        }
        
        @MainActor
        func handleFetchError() {
            self.weatherCache = nil
            self.isOtherApiError = true
        }
        
        @MainActor
        internal func setIsLoading(_ loading: Bool) {
            self.isLoading = loading
        }
    }
}
