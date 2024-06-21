//
//  Weather.swift
//  WeatherApp
//
//  Created by 강석호 on 6/21/24.
//

import UIKit

struct WeatherResponse: Decodable {
    let main: Main
    let wind: Wind
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
    let humidity: Double
}

struct Wind: Decodable {
    let speed: Double
}

struct Weather: Decodable {
    let icon: String
}
