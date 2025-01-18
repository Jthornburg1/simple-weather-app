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
        static let regularFont = "Poppins-Regular"
        static let semiBoldFont = "Poppins-SemiBold"
        static let humidity = "Humidity"
        static let uv = "UV"
        static let feelsLike = "Feels Like"
        
        // Colors
        static let text242 = Color(red: 242/255, green: 242/255, blue: 242/255)
        static let text196 = Color(red: 196/255, green: 196/255, blue: 196/255)
        static let text154 = Color(red: 154/255, green: 154/255, blue: 154/255)
    }
    
    @StateObject private var viewModel: ViewModel
    @State private var viewState: WeatherViewState
    
    init(searchViewModel: ViewModel = ViewModel()) {
        _viewModel = StateObject(wrappedValue: searchViewModel)
        self.viewState = searchViewModel.weatherCache == nil ? .initial : .detailed
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
                    viewState: $viewState,
                    weatherImage: viewModel.weatherImage,
                    cityName: viewModel.weatherCache?.locationName ?? "",
                    temp: viewModel.weatherCache?.celsiusDegrees ?? 0
                )
            case .detailed:
                DetailedState(weatherImage: self.viewModel.weatherImage, weatherData: self.viewModel.weatherCache)
            }
        }
        .padding()
        .task {
            viewModel.handleIntialImage()
        }
        Spacer()
    }
    
    struct InitialViewState: View {
        var body: some View {
            Spacer()
            VStack(spacing: 16) {
                Text(Constants.initialViewTitle)
                    .font(.custom(Constants.semiBoldFont, size: 30))
                Text(Constants.initialViewSubtitle)
                    .font(.custom(Constants.semiBoldFont, size: 15))
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
                        if self.viewModel.weatherCache != nil {
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
        @Binding var viewState: WeatherViewState
        let weatherImage: Image?
        let cityName: String
        let temp: Int
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(cityName)
                        .font(.custom(Constants.semiBoldFont, size: 20))
                    HStack(alignment: .top, spacing: 0) {
                        Text("\(Int(temp))")
                            .font(.custom(Constants.semiBoldFont, size: 60))
                        Text("°")
                            .font(.custom(Constants.regularFont, size: 20))
                            .baselineOffset(-10)
                    }
                }
                .padding(.leading, 16)
                Spacer()
                if let weatherImage = weatherImage {
                    weatherImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.trailing, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Constants.text242)
            .cornerRadius(16)
            .padding(.horizontal)
            .onTapGesture {
                viewState = .detailed
            }
        }
    }
    
    struct DetailedState: View {
        let weatherImage: Image?
        let weatherData: WeatherCache?
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                if let weatherImage = weatherImage {
                    weatherImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
                Text(weatherData?.locationName ?? "")
                    .font(.custom(Constants.semiBoldFont, size: 30))
                HStack(alignment: .top, spacing: 0) {
                    Text("\(Int(weatherData?.celsiusDegrees ?? 0))")
                        .font(.custom(Constants.semiBoldFont, size: 70))
                    Text("°")
                        .font(.custom(Constants.regularFont, size: 30))
                        .baselineOffset(-10)
                }
            }
            .padding(.top, 20)
            GranularDataView(weatherData: weatherData)
        }
    }
    
    struct GranularDataView: View {
        let weatherData: WeatherCache?
        
        var body: some View {
            HStack(alignment: .center, spacing: 50) {
                VStack(alignment: .center) {
                    Text(Constants.humidity)
                        .font(.custom(Constants.regularFont, size: 12))
                        .foregroundColor(Constants.text196)
                    Text("\(Int(weatherData?.humidity ?? 0))%")
                        .font(.custom(Constants.regularFont, size: 15))
                        .foregroundColor(Constants.text154)
                }
                VStack {
                    Text(Constants.uv)
                        .font(.custom(Constants.regularFont, size: 12))
                        .foregroundColor(Constants.text196)
                    Text("\(Int(weatherData?.uv ?? 0))")
                        .font(.custom(Constants.regularFont, size: 15))
                        .foregroundColor(Constants.text154)
                }
                VStack {
                    Text(Constants.feelsLike)
                        .font(.custom(Constants.regularFont, size: 12))
                        .foregroundColor(Constants.text196)
                    Text("\(Int(weatherData?.feelsLikeCelsius ?? 0))")
                        .font(.custom(Constants.regularFont, size: 15))
                        .foregroundColor(Constants.text154)
                }
            }
            .padding()
            .background(Constants.text242)
            .cornerRadius(16)
        }
    }
    
    struct ErrorState: View {
        let message: String
        
        var body: some View {
            Spacer()
            Text(message)
                .font(.custom(Constants.regularFont, size: 20))
                .foregroundColor(.red)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    WeatherView()
}
