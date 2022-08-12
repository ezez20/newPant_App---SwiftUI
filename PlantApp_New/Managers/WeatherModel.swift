//
//  WeatherModel.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 7/3/22.
//

import Foundation

struct WeatherModel {
    var conditionId: Int
    var cityName: String
    var temperature: Double
    
    var teperatureString: String {
        return String(format: "%.0f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt.rain"
        case 300...321:
            return "cloud.rain"
        case 500...531:
            return "cloud.heavyrain"
        case 600...621:
            return "cloud.snow"
        case 801...804:
            return "cloud"
        default:
            return "sun.max"
        }
    }
    
    
}
