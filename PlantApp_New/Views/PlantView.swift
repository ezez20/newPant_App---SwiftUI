//
//  PlantView.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 7/10/22.
//

import SwiftUI

struct PlantView: View {
    
    // MARK: - PRESISTED DATA
    
    // CORE DATA: PLANT entity
    let plant: Plant
    @Environment(\.managedObjectContext) var moc
    
    // To dismiss view.
    @Environment(\.dismiss) var dismiss
    
    
    var weather: WeatherData
//    @State var weatherDataState: WeatherData
    @State var weatherModel = WeatherModel(conditionId: 0, cityName: "n/a", temperature: 0)
    @State var currentTemp = "Weather temp..."
    @State var currentTempIcon = Image(systemName: "questionmark")
    @State var currentCity = "Current city..."
    @StateObject var weatherManager = WeatherManager()
    let tempUnitsOption = ["imperial", "celsius"]
    @State var tempUnitChosen = "imperial"
    @State var tempUnitChosenSymbol = "F"
    @State var showTempUnitSettings = false
    // MARK: - WEATHER variables
    @StateObject var locationManager = LocationManager()
    
    @State var plantImage = "UnknownPlant"
    @State var currentDate = Date.now
    @State var selectedWateredDate = Date()
    @State var waterHabit = 7
    
    @State var showingEditPlantScreen = false
    
    // TO DO: add more plants and images
    let imageSetNames = ["monstera", "pothos"]
    var dateNow = Date.now
    
    
    var happinessLevelFormatted: Int {
        var happiness = 80.0
        
        if selectedWateredDate != currentDate {
            if nextWaterDate < currentDate {
                happiness = 0
            } else {
                let happinessLevelCalc = ((Double(DateInterval(start: currentDate, end: nextWaterDate).duration))) / ((Double(DateInterval(start: selectedWateredDate, end: nextWaterDate).duration))) * 100
                happiness = Double(happinessLevelCalc)
            }
        } else if selectedWateredDate == currentDate {
            happiness = 100
        }
        return Int(happiness)
    }
    
    var nextWaterDate: Date {
        let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabit, to: selectedWateredDate.advanced(by: 86400))
        return calculatedDate!
    }
    
    var waterStatus: String {
        
        let dateIntervalFormat = DateComponentsFormatter()
        dateIntervalFormat.allowedUnits = .day
        dateIntervalFormat.unitsStyle = .short
        let formatted = dateIntervalFormat.string(from: currentDate, to: nextWaterDate) ?? ""
        if formatted == "0 days" || nextWaterDate < currentDate {
            return "Please water me ):"
        } else if dateFormatter.string(from: selectedWateredDate) == dateFormatter.string(from: currentDate) {
            return "Water in \(waterHabit) days"
        } else {
            return "Water in: \(formatted)"
        }
        
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    
    // MARK: - Body View
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .center) {
                
                // Top half view
                ZStack(alignment: .top) {
                    
                    Rectangle()
                        .fill(.linearGradient(colors: [Color.white, Color.white, Color.green], startPoint: .top, endPoint: .bottom))
                        .cornerRadius(50)
                    
                    
                    VStack {
                        // PLANT PICTURE
                            if imageSetNames.contains(plant.plantImageString ?? "UnknownPlant") {
                                Image(plant.plantImageString!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                loadedImage(with: plant.imageData)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        
                        // Plant name, Happiness level, weather, date
                        VStack {
                            // Plant Name, Leaf logo
                            HStack {
                                Image(systemName: "leaf.circle")
                                Text(plant.plant ?? "Unknown")
                            }
                            .font(.title2)
                            .padding(1)
                            
                            // Happiness level
                            HStack {
                                Image(systemName: "face.smiling")
                                Text("\(happinessLevelFormatted)%")
                            }
                            .padding(1)
                            .foregroundColor(Color.white)

                            // Weather
                            HStack {
                                VStack {
                                    HStack {
                                        Image(systemName: weatherModel.conditionName)
                                        Text("\(weatherModel.teperatureString) \(tempUnitChosenSymbol)")
                                    }
                                    Text(weatherModel.cityName)
                                    
                                }
                                .onTapGesture {
                                    showTempUnitSettings.toggle()
                                }
                                
                                Spacer()
                                VStack {
                                    Image(systemName: "calendar")
                                    Text("\(currentDate.formatted(date: .abbreviated, time: .omitted))")
                                }
                            }
                            .frame(width: 300, height: 30)
                            .font(.system(size: 20))
                        }
                        .padding(.bottom)
                        .foregroundColor(.white)
                    }
                    .padding(.top)
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                
                
                Spacer(minLength: 60)
                
                // PLANT STATUS BOX
                VStack(alignment: .center, spacing: 0) {
                    
                    Text("Watering habit:")
                        .font(.title2)
                        .padding()
                    
                    HStack {
                        Image(systemName: "drop.circle")
                        Text(waterStatus)
                    }
                    
                    
                    HStack {
                        Text("Last watered:")
                        
                        Group {
                            DatePicker("label", selection: $selectedWateredDate, in: ...currentDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .id(selectedWateredDate)
                                .labelsHidden()
                                .frame(width: 150, height: 50, alignment: .center)
                                .clipped()
                        }
                        .colorInvert()
                        .colorMultiply(Color("custom_blue_1"))
                        
                        
                    }
                    .padding(0)
                    .font(.body)
                   
                    
                }
                .padding()
                .frame(width: 350, height: 150)
                .background(.white)
                .foregroundColor(Color("custom_blue_1"))
                .cornerRadius(10)
                .shadow(radius: 5)
                
                Spacer()
                
                // WATER BUTTON
                Button(action: { water() } ) {
                    Image(systemName: "drop")
                        .font(.largeTitle)
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("custom_blue_1"))
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
            }
            .padding(.bottom, 10)
            .onAppear {
                parseJSON(weather)
            }
            
            // Back button, Edit Plant button - STACKED ON ZSTACK
                HStack {
                    Button {
                        update()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .background(.white)
                            .font(.largeTitle)
                            .clipShape(Circle())
                            
                    }
                    
                    Spacer()
                    
                    Button {
//                        // Lead to settings screen (to adjust water habit time)
                        update()
                        showingEditPlantScreen = true
                        
                    } label: {
                        Image(systemName: "pencil")
                            .background(.white)
                            .font(.largeTitle)
                            .clipShape(Circle())
                            
                    }
                }
                .foregroundColor(.green)
                .font(.largeTitle)
                .padding()
               
        }
        .onAppear { // of ZStack
            // BUG: figure out why when plant is edited, "Last watered" is not updated.
            selectedWateredDate = plant.lastWateredDate!
            waterHabit = Int(plant.waterHabit)
        }
        .sheet(isPresented: $showingEditPlantScreen, onDismiss: updateUI) {
            EditPlantView(currentPlant: plant)
        }
        .sheet(isPresented: $showTempUnitSettings) {
       
                Picker("Unit Selected", selection: $tempUnitChosen) {
                    ForEach(tempUnitsOption, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: tempUnitChosen) { _ in
                    switchTempUnit()
                }
                
            
        }
        
        
        
       
        
    }
    
    // MARK: - Methods
    
    //  Water function
    func water()  {
        selectedWateredDate = currentDate
    }
    
    func parseJSON(_ weatherData: WeatherData) {
        
        let decodedData = weatherData
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        var convertedTemp = 0.0
        
        if tempUnitChosen == "imperial" {
            convertedTemp = temp
            tempUnitChosenSymbol = "°F"
        } else {
            convertedTemp = (temp - 32) / (1.8000)
            tempUnitChosenSymbol = "°C"
        }
        
        weatherModel = WeatherModel(conditionId: id, cityName: name, temperature: convertedTemp)
        print(weatherModel)
        
    }
    
    // Updates CoreData
    func update() {
        plant.lastWateredDate = selectedWateredDate
        try? moc.save()
        print("Plant updated")
    }
    
    func updateUI() {
        selectedWateredDate = plant.lastWateredDate ?? Date()
        waterHabit = Int(plant.waterHabit)
    }
    
    func loadedImage(with imageData: Data?) -> Image {
        guard let imageData = imageData else {
            return Image("UnknownPlant")
        }
        let loadedImage = UIImage(data: imageData)
        return Image(uiImage: loadedImage!)
    }
    
    func switchTempUnit() {
//        weatherManager.tempUnit = tempUnitChosen
//        print("Current TempUnit: \(weatherManager.tempUnit)")

            parseJSON(weather)
    }
    
    
}

// MARK: - Preview
//struct PlantView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlantView(weather: previewWeather)
//    }
//}
