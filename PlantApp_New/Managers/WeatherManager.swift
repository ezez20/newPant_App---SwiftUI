//
//  WeatherManager.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 6/25/22.
//

import Foundation
import CoreLocation
import SwiftUI

class WeatherManager: ObservableObject  {
//    @Published var tempUnit = "imperial"
    
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> WeatherData {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?appid=59e5528b1290740dbf606135a6c7c7a0&units=imperial&lat=\(latitude)&lon=\(longitude)") else {
            fatalError("Missing URL")
        }
    
    
    let urlRequest = URLRequest(url: url)
    
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error fetching weather data.")
        }
        
        let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
//        print(decodedData)

        return decodedData
        
    }


    
    
}
