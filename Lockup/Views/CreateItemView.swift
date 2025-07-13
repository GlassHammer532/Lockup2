import SwiftUI
import PhotosUI
import UIKit
import Vision

struct CreateItemView: View {
    @State private var name = ""
    @State private var photoData: Data?
    @State private var x = 0
    @State private var y = 0
    @State private var z = 0
    @State private var description = ""
    @State private var selectedCategory: Category?
    @State private var selectedStorageSpace: StorageSpace?
    @ObservedObject var itemsStore: ItemsStore
    @ObservedObject var categoryStore: CategoryStore
    @ObservedObject var storageSpaceStore: StorageSpaceStore
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isRecognizing = false
    @State private var recognitionError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Mandatory").font(.title2).bold()

                // Name Field
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Photo Picker with Vision suggestion
                PhotosPicker(selection: $photoPickerItem, matching: .images, photoLibrary: .shared()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                            .frame(height: 120)
                        if let data = photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(8)
                        } else {
                            Text("Add Photo")
                        }
                    }
                }
                .onChange(of: photoPickerItem) { item in
                    guard let item else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            photoData = data
                            isRecognizing = true
                            recognitionError = nil
                            ImageRecognitionHelper.recognizeObjectName(from: data) { suggestion in
                                DispatchQueue.main.async {
                                    isRecognizing = false
                                    name = suggestion ?? name
                                    if suggestion == nil { recognitionError = "No suggestion found" }
                                }
                            }
                        }
                    }
                }

                if isRecognizing {
                    HStack {
                        ProgressView()
                        Text("Analyzing…").font(.caption).foregroundColor(.secondary)
                    }
                }
                if let err = recognitionError {
                    Text(err).font(.caption).foregroundColor(.red)
                }

                // Storage Space Picker
                VStack(alignment: .leading) {
                    Text("Storage Space").font(.headline)
                    Picker("Space", selection: $selectedStorageSpace) {
                        Text("Select Space").tag(StorageSpace?.none)
                        ForEach(storageSpaceStore.storageSpaces) { space in
                            HStack {
                                Circle().fill(space.color).frame(width: 14, height: 14)
                                Text(space.name)
                            }
                            .tag(Optional(space))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // Position Picker
                if let space = selectedStorageSpace {
                    DynamicPositionPicker(x: $x, y: $y, z: $z, storageSpace: space)
                } else {
                    Text("Please select a storage space above.")
                        .italic().foregroundColor(.secondary)
                }

                Divider().padding(.vertical)

                Text("Optional").font(.title2).bold()
                TextField("Description", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    Text("None").tag(Category?.none)
                    ForEach(categoryStore.categories) { cat in
                        HStack {
                            Circle().fill(cat.color).frame(width: 14, height: 14)
                            Text(cat.name)
                        }
                        .tag(Optional(cat))
                    }
                }
                .pickerStyle(MenuPickerStyle())

                // Create Button
                Button("Create Item") {
                    guard !name.isEmpty, photoData != nil, let space = selectedStorageSpace else { return }
                    let item = StorageItem(
                        name: name,
                        photoData: photoData,
                        positionX: x,
                        positionY: y,
                        positionZ: z,
                        description: description.isEmpty ? nil : description,
                        categories: selectedCategory.map { [$0] } ?? [],
                        storageSpace: space
                    )
                    itemsStore.items.append(item)
                    // Reset form:
                    name = ""; photoData = nil
                    x = 0; y = 0; z = 0
                    description = ""; selectedCategory = nil
                    selectedStorageSpace = nil
                }
                .disabled(name.isEmpty || photoData == nil || selectedStorageSpace == nil)
                .frame(maxWidth: .infinity)
                .padding()
                .background((name.isEmpty || photoData == nil || selectedStorageSpace == nil) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Create Item")
    }
}
