//
//  AddPlantView.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 7/25/22.
//

import SwiftUI


struct AddPlantView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(sortDescriptors: [
        
        // Sort by "title" in default (alphabetical order)
        SortDescriptor(\.dateAdded)
        
//        // add another sort, by "author"
//        SortDescriptor(\.lastWateredDate)
        
    ]) var plants: FetchedResults<Plant>
    
    @State private var plant = ""
    @State private var plantImageString = ""
    @State private var waterHabit = 7
    @State private var lastWatered = Date()
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    let waterTimes = [4,5,6,7,8,9,10]
    // ADD: add more plants and images
    let imageSetNames = ["monstera", "pothos"]
    @State private var showSuggestionsList = false
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    ZStack {
                        TextField( "Type of plant", text: Binding<String>(
                                get: { return plant }, set: {
                                    plant = $0

                                    let trimmedAndLoweredText = plant.trimmingCharacters(in: .whitespaces).lowercased()
                                    
                                    guard plant.count >= 1, trimmedAndLoweredText != "" else {
                                        plantImageString = ""
                                        return
                                    }
                                    
                                    if plant != "" {
                                        showSuggestionsList = true
                                        print(plant.count)
                                    } else {
                                        showSuggestionsList = false
                                        print("false")
                                    }

                                    plantImageString = trimmedAndLoweredText
                                })) {
                            showSuggestionsList = false
                            UIApplication.shared.endEditing()
                        }
                        .frame(height: 30)
                        
                        HStack {
                            Spacer()
                            
                            if showSuggestionsList {
                                Button(action: {
                                    plant = ""
                                    showSuggestionsList = false
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .padding(.vertical)
                                        .foregroundColor(.green)
                                })
                                
                            }
                        }
                        .frame(height: 30)
                    }
                    
                    if showSuggestionsList {
                        ScrollView {
                            ForEach(imageSetNames.filter({ "\($0)".contains(plant.lowercased()) }), id: \.self) { plantSuggest in
                                HStack {
                                    Text("\(plantSuggest)")
                                        .padding()
                                        .frame(height: 30)
                                    Spacer()
                                }
                                .onTapGesture {
                                    plant = plantSuggest
                                    showSuggestionsList = false
                                }
                            }
                        }
                    }
                }
                
                Section {
                    // Calendar
                    Picker("Water Habit:", selection: $waterHabit) {
                        ForEach(4...12, id: \.self) { days in
                            Text(" Water every \(days) days")
                        }
                    }
                    HStack {
                        Text("Last watered:")
                        Group {
                            DatePicker("label", selection: $lastWatered, in: ...Date.now, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .id(lastWatered)
                                .labelsHidden()
                                .frame(width: 150, height: 50, alignment: .center)
                                .clipped()
                        }
                        .colorInvert()
                        .colorMultiply(.black)
                    }
                } header: {
                    Text("Watering")
                }
                
                Section {
                    Button("Add Plant") {
                        let newPlant = Plant(context: moc)
                        newPlant.id = UUID()
                        newPlant.dateAdded = Date.now
                        newPlant.order = (plants.last?.order ?? 0) + 1
                        
                        newPlant.plant = plant
                        newPlant.waterHabit = Int16(waterHabit)
                        newPlant.lastWateredDate = lastWatered
                        if imageSetNames.contains(plantImageString) && inputImage == nil {
                            newPlant.plantImageString = plantImageString
                        } else if imageSetNames.contains(plantImageString) && inputImage != nil {
                            newPlant.plantImageString = ""
                        } else if inputImage != nil {
                            newPlant.plantImageString = ""
                        } else {
                            newPlant.plantImageString = "UnknownPlant"
                        }
                        
                        if customImageData() != nil {
                            newPlant.imageData = customImageData()
                        }
                        
                        try? moc.save()
                        dismiss()
                    }
                    .disabled(validateEntry())
                }
                
                Section {
                    if imageSetNames.contains(plantImageString) && inputImage == nil {
                        Image(plantImageString)
                            .resizable()
                            .scaledToFit()
                    } else if imageSetNames.contains(plantImageString) && inputImage != nil {
                        Image(uiImage: inputImage!)
                            .resizable()
                            .scaledToFit()
                    } else if inputImage != nil  {
                        Image(uiImage: inputImage!)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("UnknownPlant")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .onTapGesture {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
            }
            .navigationTitle("Add Plant")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Current: Camera to take own plant picture.
                        sourceType = .camera
                        showingImagePicker = true
                        
                        // Future idea
                        // Open Camera for ML to identify plant
                        // Need to add
                        // CoreML Model
                        // Download a Caffe Model and then convert it to MLModel. Use Section 24: 331 for reference.
                    } label: {
                        // FUTURE: make a custom "Camera-Plant" SF symbol to use. OR just find a custom Image.
                        ZStack {
                            Image(systemName: "camera.metering.center.weighted.average")
                            Image(systemName: "leaf")
                                .resizable()
                                .frame(width: 10, height: 10)
                        }
                        .scaledToFit()
                    }
                    
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: sourceType ,selectedImage: self.$inputImage)
            }
        }
        
    }
    
    func validateEntry() -> Bool {
        if plant.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func customImageData () -> Data? {
        let pickedImage = inputImage?.jpegData(compressionQuality: 0.80)
        return pickedImage
    }
    
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddPlantView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantView()
    }
}
