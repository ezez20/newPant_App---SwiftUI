//
//  EditPlantView.swift
//  PlantApp_New
//
//  Created by Ezra Yeoh on 7/29/22.
//

import SwiftUI

struct EditPlantView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let currentPlant: Plant
    
    @State private var currentPlantName = ""
    @State private var plantImageString = ""
    @State private var waterHabit = 7
    @State private var lastWatered = Date()
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
   
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    let waterTimes = [4,5,6,7,8,9,10]
    // ADD: add more plants and images
    let imageSetNames = ["monstera", "pothos"]
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    TextField("Rename Plant...", text: Binding<String>( get: {
                        return currentPlantName
                    }, set: {
                        currentPlantName = $0
                        
                        let trimmedAndLoweredText = currentPlantName.trimmingCharacters(in: .whitespaces).lowercased()
                        
                        guard currentPlantName.count >= 1, trimmedAndLoweredText != "" else {
                            plantImageString = ""
                            return
                        }
                        
                        plantImageString = trimmedAndLoweredText
                    }))
                    
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
                            DatePicker("label", selection: $lastWatered, in: ...Date(), displayedComponents: [.date])
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
                    Button("Update Plant") {
                        
                        currentPlant.plant = currentPlantName
                        currentPlant.waterHabit = Int16(waterHabit)
                        currentPlant.lastWateredDate = lastWatered
                        if imageSetNames.contains(plantImageString) && inputImage == nil {
                            currentPlant.plantImageString = plantImageString
                        } else if imageSetNames.contains(plantImageString) && inputImage != nil {
                            currentPlant.plantImageString = ""
                        } else if inputImage != nil {
                            currentPlant.plantImageString = ""
                        } else {
                            currentPlant.plantImageString = "UnknownPlant"
                        }
                        
                        if customImageData() != nil {
                            currentPlant.imageData = customImageData()
                        }
                        
                        try? moc.save()
                        dismiss()
                    }
                    .disabled(validateEntry())
                }
                
                Section {
                    // if plant used "Set Photos" and there is NO CUSTOM IMAGE.
                    if imageSetNames.contains(currentPlant.plantImageString ?? "UnknownPlant") && inputImage == nil {
                        Image(plantImageString)
                            .resizable()
                            .scaledToFit()
                    // if plant used "Set Photos" and used a CUSTOM IMAGE
                    } else if imageSetNames.contains(currentPlant.plantImageString ?? "UnknownPlant") && inputImage != nil {
                        loadedImage(with: currentPlant.imageData)
                            .resizable()
                            .scaledToFit()
                    // if plant used CUSTOM NAME and used CUSTOM IMAGE
                    } else if currentPlant.imageData != nil && inputImage == nil {
                        loadedImage(with: currentPlant.imageData)
                            .resizable()
                            .scaledToFit()
                    // present user's new chosen photo
                    } else if inputImage != nil  {
                        Image(uiImage: inputImage!)
                            .resizable()
                            .scaledToFit()
                    // present UnknownPlant if user didn't use "Set Photos" or chose custom photo.
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
                
                Section {
                    Button("Delete Plant") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .alert("Important message", isPresented: $showingDeleteAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive ) {
                            deletePlant(plant: currentPlant)
                            dismiss()
                        }
                        } message: {
                                Text("Are you sure you want to delete this plant?")
                        }
                }
            }
            .navigationTitle("Edit Plant")
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
        .onAppear {
            // BUG: figure out why when plant is edited, "Last watered" is not updated.
            currentPlantName = currentPlant.plant ?? ""
            lastWatered = currentPlant.lastWateredDate!
            waterHabit = Int(currentPlant.waterHabit)
        }
        
    }
    
    func validateEntry() -> Bool {
        if currentPlantName.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func customImageData () -> Data? {
        let pickedImage = inputImage?.jpegData(compressionQuality: 0.80)
        return pickedImage
    }
    
    func deletePlant(plant: Plant) {
        moc.delete(plant)
        try? moc.save()
    }
    
    func loadedImage(with imageData: Data?) -> Image {
        guard let imageData = imageData else {
            return Image("UnknownPlant")
        }
        let loadedImage = UIImage(data: imageData)
        return Image(uiImage: loadedImage!)
    }
    
}


//struct EditPlantView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditPlantView(currentPlant: plant)
//    }
//}
