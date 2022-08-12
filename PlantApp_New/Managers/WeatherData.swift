//
//  WeatherData.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 6/25/22.
//

import Foundation

struct WeatherData: Codable {
    var name: String
    var main: Main
    var weather: [Weather]
}

struct Main: Codable {
    var temp: Double
}

struct Weather: Codable {
    var description: String
    var id: Int
}


