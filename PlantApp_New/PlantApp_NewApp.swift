//
//  PlantApp_NewApp.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 3/26/22.
//

import SwiftUI

@main
struct PlantApp_NewApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
