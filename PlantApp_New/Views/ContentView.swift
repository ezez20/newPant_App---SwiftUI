//
//  ContentView.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 3/26/22.
//

import SwiftUI
import CoreLocation
import SwiftyJSON

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [
        
        // Sort by "title" in default (alphabetical order)
        SortDescriptor(\.order),
        
//        // add another sort, by "author"
        SortDescriptor(\.dateAdded)
        
    ]) var plants: FetchedResults<Plant>
    
// MARK: - WEATHER variables
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: WeatherData?
    @State var weatherModel: WeatherModel?
    
// MARK: - AddPlant variables
    @State private var showingAddPlantScreen = false
    @State private var outputImage: UIImage?
    @State var currentDate = Date.now
    let imageSetNames = ["monstera", "pothos"]
    
  
    var body: some View {
        
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    NavigationView {
                        VStack {
                            List {
                                ForEach(plants, id: \.id) { plant in
                                    NavigationLink {
                                        PlantView(plant: plant, weather: weather, weatherModel: WeatherModel(conditionId: 0, cityName: "n/a", temperature: 0))
                                            .navigationBarBackButtonHidden(true)
                                            .navigationBarHidden(true)
                                    } label: {
                                        HStack {
                                            Text(plant.plant ?? "Unknown")
                                            Spacer()
                                           
                                            VStack {
                                                Image(systemName: "drop")
                                                    .scaledToFit()
                                                Text(displayedNextWaterDate(lastWateredDate: plant.lastWateredDate ?? currentDate, waterHabit: Int(plant.waterHabit)))
                                                    .font(.system(size: 10))
                                            }
                                            
                                            Group {
                                                if imageSetNames.contains(plant.plantImageString!) {
                                                    Image(plant.plantImageString!)
                                                        .resizable()
                                                } else if plant.plantImageString == "UnknownPlant" && plant.imageData != nil {
                                                    Image("UnknownPlant")
                                                        .resizable()
                                                } else {
                                                    loadedImage(with: plant.imageData)
                                                        .resizable()
                                                }
                                            }
                                            .scaledToFit()
                                            .frame(width: 30, height: 50)
                                        }
                                    }
                                    .swipeActions {
                                        Button {
                                            plant.lastWateredDate = currentDate
                                            try? moc.save()
                                        } label: {
                                            Label("Watered", systemImage: "drop")
                                        }
                                        .tint(waterStatusLevelColor(lastWateredDate: plant.lastWateredDate!, waterHabit: plant.waterHabit))
                                    }
                                }
                                .onMove(perform: moveItem)
                                .deleteDisabled(true)
                            }
                        }
                        .sheet(isPresented: $showingAddPlantScreen) {
                            AddPlantView()
                        }
                        .navigationTitle("Plants")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                EditButton()
                                    .foregroundColor(.green)
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    showingAddPlantScreen.toggle()
                                } label: {
                                    Label("Add Plant", systemImage: "plus")
                                }
                                .foregroundColor(.green)
                            }
                        }
                       

                    }
                } else {
                    LoadingView() // MARK: - Present Loading Screen WHILE WEATHER LOADS
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error getting weather: \(error)")
                            }
                        }
                }
            } else {
                if locationManager.isLoading { // MARK: - load location for weather.
                    LoadingView()
                } else {
                    WelcomeView() // MARK: - WelcomeView asking for user to allow to use location for weather.
                        .environmentObject(locationManager)
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
            
        }
        
        
    }
    
// MARK: - load saved image from CoreData
    func loadedImage(with imageData: Data?) -> Image {
        guard let imageData = imageData else {
//            print("Error outputing imageData")
            return Image("UnknownPlant")
        }
        let loadedImage = UIImage(data: imageData)
        return Image(uiImage: loadedImage!)
    }

// MARK: - Delete is currently disabled in ContentView
//    func deletePlant(at offsets: IndexSet) {
//        for offset in offsets {
//            let plant = plants[offset]
//            moc.delete(plant)
//        }
//
//        try? moc.save()
//    }

// MARK: - Allow users to move items on accross different rows on List.
    func moveItem(at sets:IndexSet,destination:Int) {
            let itemToMove = sets.first!
            
            if itemToMove < destination{
                var startIndex = itemToMove + 1
                let endIndex = destination - 1
                var startOrder = plants[itemToMove].order
                while startIndex <= endIndex{
                    plants[startIndex].order = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                plants[itemToMove].order = startOrder
            } else if destination < itemToMove{
                var startIndex = destination
                let endIndex = itemToMove - 1
                var startOrder = plants[destination].order + 1
                let newOrder = plants[destination].order
                while startIndex <= endIndex{
                    plants[startIndex].order = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                plants[itemToMove].order = newOrder
            }
            
            do {
                try moc.save()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    
    func displayedNextWaterDate(lastWateredDate: Date, waterHabit: Int) -> String {
        // Work on implementing in ForEach List.
        var nextWaterDate: Date {
            let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabit, to: lastWateredDate.advanced(by: 86400))
            return calculatedDate!
        }
        
        var waterStatus: String {
            
            let dateIntervalFormat = DateComponentsFormatter()
            dateIntervalFormat.allowedUnits = .day
            dateIntervalFormat.unitsStyle = .short
            let formatted = dateIntervalFormat.string(from: currentDate, to: nextWaterDate) ?? ""
            if formatted == "0 days" || nextWaterDate < currentDate {
                return "Please water me ):"
            } else if dateFormatter.string(from: lastWateredDate) == dateFormatter.string(from: currentDate) {
                return "in \(waterHabit) days"
            } else {
                return "in \(formatted)"
            }
            
        }
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }
        return waterStatus
    }
 
// MARK: - Swipe to water. Water level status: Green(100-70), Yellow(69-30), Red(29...0)
    func waterStatusLevelColor(lastWateredDate: Date, waterHabit: Int16) -> Color {
        var happinessLevelFormatted: Int {
            var happiness = 80.0
            
            var nextWaterDate: Date {
                let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: Int(waterHabit), to: lastWateredDate.advanced(by: 86400))
                return calculatedDate!
            }
            
            if lastWateredDate != currentDate {
                if nextWaterDate < currentDate {
                    happiness = 0
                } else {
                    let happinessLevelCalc = ((Double(DateInterval(start: currentDate, end: nextWaterDate).duration))) / ((Double(DateInterval(start: lastWateredDate, end: nextWaterDate).duration))) * 100
                    happiness = Double(happinessLevelCalc)
                }
            } else if lastWateredDate == currentDate {
                happiness = 100
            }
            return Int(happiness)
        }
        
        switch happinessLevelFormatted {
        case 70...100:
            return .green
        case 30...69:
            return .yellow
        default:
            return .red
        }
    }
    
    
    
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weather: previewWeather)
    }
}
    





