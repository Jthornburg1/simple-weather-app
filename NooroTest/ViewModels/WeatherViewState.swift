//
//  WeatherViewState.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/23/25.
//

enum WeatherViewState {
    case initial
    case loading
    case loaded
    case detailed
    case error(String)
}

