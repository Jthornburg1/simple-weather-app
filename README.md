# Weather App

A SwiftUI weather application that allows users to see a display of weather for a given location.

## Features

- Search for weather by location name
- View current temperature and weather conditions
- Detailed view showing additional metrics (humidity, UV index, feels-like temperature)
- Persistent data storage using UserDefaults
- Error handling for various API scenarios

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository
```bash
git clone https://github.com/Jthornburg1/simple-weather-app.git
cd simple-weather-app
```
2. Open in Xcode
```bash
open NooroTest.xcodeproj
```
3 Run in the simulator with Xcode GUI. There are no dependencies to install.

## Note
With an additional 30 minutes, I would detangle the `performSearch` and `fetchImage` functions from the ViewModel and wrap them in a networking layer that conforms to a protocol. This way the ViewModel would be networking would be mockable and the ViewModel, testable.

