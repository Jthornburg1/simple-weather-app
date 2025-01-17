//
//  WeatherView.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/15/25.
//

import SwiftUI

enum WeatherViewState {
    case initial
    case loading
    case loaded
    case detailed
    case error(String)
}

struct WeatherView: View {
    enum Constants {
        static let textFieldPlaceholder = "Search Location"
        static let initialViewTitle = "No City Selected"
        static let initialViewSubtitle = "Please Search For A City"
    }
    
    @StateObject private var viewModel: ViewModel
    @State private var viewState: WeatherViewState = .initial
    
    init(searchViewModel: ViewModel = ViewModel()) {
        _viewModel = StateObject(wrappedValue: searchViewModel)
    }
    
    var body: some View {
        VStack {
            SearchTextField(
                onSearch: {
                    self.viewState = .loading
                    viewModel.updateValues()
                },
                text: $viewModel.searchTerm
            )
            
            switch self.viewState {
            case .initial:
                InitialViewState()
            case .loading:
                LoadingState(viewState: $viewState, viewModel: self.viewModel)
            case .error(let message):
                ErrorState(message: message)
            case .loaded:
                LoadedState(
                    weatherImage: viewModel.weatherImage,
                    cityName: viewModel.weatherResponse?.location?.name ?? "",
                    temp: viewModel.weatherResponse?.current?.celsiusDegrees ?? 0
                )
            default:
                InitialViewState()
            }
        }
        .padding()
    }
    
    struct InitialViewState: View {
        var body: some View {
            Spacer()
            VStack(spacing: 16) {
                Text(Constants.initialViewTitle)
                    .font(.custom("Poppins-SemiBold", size: 30))
                Text(Constants.initialViewSubtitle)
                    .font(.custom("Poppins-SemiBold", size: 15))
            }
            .frame(maxHeight: .infinity)
            Spacer()
        }
    }
    
    struct LoadingState: View {
        @Binding var viewState: WeatherViewState
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            Spacer()
            ProgressView()
                .onChange(of: self.viewModel.isLoading) { _, newValue in
                    if !newValue {
                        if self.viewModel.weatherResponse != nil {
                            self.viewState = .loaded
                        } else if self.viewModel.weatherFetchError != nil {
                            switch self.viewModel.weatherFetchError?.error?.code {
                            case 1003:
                                self.viewState = .error("You must provide a location to search view weather.")
                            case 1006:
                                self.viewState = .error("The search term you entered didn't match a location in our records.")
                            default:
                                self.viewState = .error("There was an error on our side. Please try again.")
                            }
                        }
                    }
                }
            Spacer()
        }
    }
    
    struct LoadedState: View {
        let weatherImage: Image?
        let cityName: String
        let temp: Double
        
        var body: some View {
            Text("Hi there")
        }
    }
    
    struct ErrorState: View {
        let message: String
        
        var body: some View {
            Spacer()
            Text(message)
                .font(.custom("Poppins-Regular", size: 20))
                .foregroundColor(.red)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 10)
        }
        
    }
}

#Preview {
    WeatherView()
}
