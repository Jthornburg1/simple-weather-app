//
//  WeatherView.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/15/25.
//

import SwiftUI

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
    
    @ObservedObject private var viewModel: ViewModel
    @State private var viewState: WeatherViewState
    
    /**The strategy here is that a subclass of ViewModel can be created for the tests*/
    init(searchViewModel: ViewModel = ViewModel()) {
        _viewModel = ObservedObject(initialValue: searchViewModel)
        self.viewState = searchViewModel.weatherCache == nil ? .initial : .detailed
    }
    
    var body: some View {
        VStack(spacing: 20) {
            SearchTextField(
                onSearch: {
                    self.viewState = .loading
                    viewModel.updateValues()
                },
                text: $viewModel.queryTerm
            )
            
            switch self.viewModel.viewState {
            case .initial:
                InitialViewState()
            case .loading:
                Spacer()
                ProgressView()
                Spacer()
            case .error(let message):
                ErrorState(message: message)
            case .loaded:
                LoadedState(
                    viewModel: self.viewModel,
                    cityName: viewModel.weatherCache?.locationName ?? "",
                    temp: viewModel.weatherCache?.celsiusDegrees ?? 0
                )
            case .detailed:
                DetailedState(weatherData: self.viewModel.weatherCache)
            }
        }
        .padding()
        .task {
            viewModel.determineInitialState()
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
    
    struct LoadedState: View {
        let viewModel: ViewModel
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
                AsyncImage(url: URL(string: "https:\(self.viewModel.weatherCache?.iconUrl ?? "")")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.trailing, 16)
                } placeholder: {
                    ProgressView()
                }

                    
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Constants.text242)
            .cornerRadius(16)
            .padding(.horizontal)
            .onTapGesture {
                viewModel.expandToDetailView()
            }
        }
    }
    
    struct DetailedState: View {
        let weatherData: WeatherCache?
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                AsyncImage(url: URL(string: "https:\(weatherData?.iconUrl ?? "")")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                } placeholder: {
                    ProgressView()
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
