//
//  WelcomeView.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 6/29/22.
//

import SwiftUI
import CoreLocationUI

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    let defaults = UserDefaults.standard
    
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Welcome to the PlantApp.")
                    .bold()
                    .font(.title)
                
                Text("Please share your location to get the weather stats.")
            }
            .multilineTextAlignment(.center)
            .padding()
            
            LocationButton(.shareCurrentLocation) {
                locationManager.requestLocation()
            }
            .cornerRadius(30)
            .symbolVariant(.fill)
            .foregroundColor(.white)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
