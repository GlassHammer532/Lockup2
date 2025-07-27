import SwiftUI
import PhotosUI
import UIKit
import Vision

struct CreateItemView: View {
    // MARK: - State Management
    @State private var currentStep: CreateItemStep = .camera
    @State private var name = ""
    @State private var photoData: Data?
    @State private var x = 0
    @State private var y = 0
    @State private var z = 0
    @State private var description = ""
    @State private var selectedCategory: Category?
    @State private var selectedStorageSpace: StorageSpace?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isRecognizing = false
    @State private var recognitionError: String? = nil
    @State private var showingCamera = false
    
    // MARK: - Store References
    @ObservedObject var itemsStore: ItemsStore
    @ObservedObject var categoryStore: CategoryStore
    @ObservedObject var storageSpaceStore: StorageSpaceStore
    
    // MARK: - Step Enumeration
    enum CreateItemStep {
        case camera
        case nameAndLocation
        case descriptionAndCategories
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressIndicatorView(currentStep: currentStep)
                
                // Content based on current step
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        switch currentStep {
                        case .camera:
                            CameraPhotoStepView(
                                photoData: $photoData,
                                photoPickerItem: $photoPickerItem,
                                showingCamera: $showingCamera,
                                isRecognizing: $isRecognizing,
                                recognitionError: $recognitionError,
                                name: $name
                            )
                        case .nameAndLocation:
                            NameAndLocationStepView(
                                name: $name,
                                selectedStorageSpace: $selectedStorageSpace,
                                x: $x,
                                y: $y,
                                z: $z,
                                storageSpaceStore: storageSpaceStore,
                                photoData: photoData
                            )
                        case .descriptionAndCategories:
                            DescriptionCategoriesStepView(
                                description: $description,
                                selectedCategory: $selectedCategory,
                                categoryStore: categoryStore
                            )
                        }
                    }
                    .padding()
                }
                
                // Navigation Buttons
                NavigationButtonsView(
                    currentStep: currentStep,
                    photoData: photoData,
                    name: name,
                    selectedStorageSpace: selectedStorageSpace,
                    onNext: nextStep,
                    onBack: previousStep,
                    onSkip: skipToFinal,
                    onCreate: createItem
                )
            }
        }
        .navigationTitle(stepTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(stepTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if #available(iOS 18.0, *) {
                setupNavigationBarForIOS18()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var stepTitle: String {
        switch currentStep {
        case .camera: return "Add Photo"
        case .nameAndLocation: return "Name & Location"
        case .descriptionAndCategories: return "Details (Optional)"
        }
    }
    
    // MARK: - Navigation Methods
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .camera:
                currentStep = .nameAndLocation
            case .nameAndLocation:
                currentStep = .descriptionAndCategories
            case .descriptionAndCategories:
                createItem()
            }
        }
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .nameAndLocation:
                currentStep = .camera
            case .descriptionAndCategories:
                currentStep = .nameAndLocation
            case .camera:
                break
            }
        }
    }
    
    private func skipToFinal() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .descriptionAndCategories
        }
    }
    
    private func createItem() {
        guard !name.isEmpty,
              photoData != nil,
              let space = selectedStorageSpace else { return }
        
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
        
        // Reset form
        resetForm()
    }
    
    private func resetForm() {
        currentStep = .camera
        name = ""
        photoData = nil
        x = 0; y = 0; z = 0
        description = ""
        selectedCategory = nil
        selectedStorageSpace = nil
        photoPickerItem = nil
        isRecognizing = false
        recognitionError = nil
    }
    
    @available(iOS 18.0, *)
    private func setupNavigationBarForIOS18() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().prefersLargeTitles = false
    }
}

// MARK: - Step Views

struct ProgressIndicatorView: View {
    let currentStep: CreateItemView.CreateItemStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(zip([CreateItemView.CreateItemStep.camera, .nameAndLocation, .descriptionAndCategories],
                            ["Camera", "Details", "Optional"])), id: \.0) { step, title in
                VStack(spacing: 4) {
                    Circle()
                        .fill(currentStep == step ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(currentStep == step ? .blue : .gray)
                }
                
                if step != .descriptionAndCategories {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct CameraPhotoStepView: View {
    @Binding var photoData: Data?
    @Binding var photoPickerItem: PhotosPickerItem?
    @Binding var showingCamera: Bool
    @Binding var isRecognizing: Bool
    @Binding var recognitionError: String?
    @Binding var name: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Capture or Select Photo")
                .font(.title2)
                .bold()
            
            Text("Start by adding a photo of your item to help with identification and organization.")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Photo Selection Area
            VStack(spacing: 16) {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .frame(height: 250)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("Add Photo")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        )
                }
                
                // Photo Action Buttons
                HStack(spacing: 16) {
                    PhotosPicker(selection: $photoPickerItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Photo Library")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    
                    Button(action: { showingCamera = true }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Camera")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                }
            }
            .onChange(of: photoPickerItem) { item in
                processSelectedImage(item)
            }
            
            // Recognition Status
            if isRecognizing {
                HStack {
                    ProgressView()
                    Text("Analyzing image for name suggestions...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
            
            if let error = recognitionError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    private func processSelectedImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData = data
                isRecognizing = true
                recognitionError = nil
                
                ImageRecognitionHelper.recognizeObjectName(from: data) { suggestion in
                    DispatchQueue.main.async {
                        isRecognizing = false
                        if let suggestion = suggestion {
                            name = suggestion
                        } else {
                            recognitionError = "Could not identify object in image"
                        }
                    }
                }
            }
        }
    }
}

struct NameAndLocationStepView: View {
    @Binding var name: String
    @Binding var selectedStorageSpace: StorageSpace?
    @Binding var x: Int
    @Binding var y: Int
    @Binding var z: Int
    @ObservedObject var storageSpaceStore: StorageSpaceStore
    let photoData: Data?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Photo Preview
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(radius: 3)
            }
            
            // Name Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Name Your Item")
                    .font(.title2)
                    .bold()
                
                TextField("Enter item name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                
                Text("AI suggested name based on your photo. You can edit this.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Storage Location Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose Storage Location")
                    .font(.title2)
                    .bold()
                
                Text("Select where you'll store this item")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Picker("Storage Space", selection: $selectedStorageSpace) {
                    Text("Select Storage Space").tag(StorageSpace?.none)
                    ForEach(storageSpaceStore.storageSpaces) { space in
                        HStack {
                            Circle()
                                .fill(space.color)
                                .frame(width: 14, height: 14)
                            Text(space.name)
                            Spacer()
                            Text("\(space.width)×\(space.height)×\(space.depth)m")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(Optional(space))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                
                // Position Picker
                if let space = selectedStorageSpace {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Specific Position (Optional)")
                            .font(.headline)
                        
                        Text("Fine-tune the exact location within \(space.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        DynamicPositionPicker(x: $x, y: $y, z: $z, storageSpace: space)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                } else {
                    Text("Please select a storage space to continue")
                        .italic()
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct DescriptionCategoriesStepView: View {
    @Binding var description: String
    @Binding var selectedCategory: Category?
    @ObservedObject var categoryStore: CategoryStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Additional Details")
                .font(.title2)
                .bold()
            
            Text("Add optional description and category to help organize your item.")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Description Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.headline)
                
                TextField("Add description (optional)", text: $description, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            Divider()
            
            // Categories Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Category")
                    .font(.headline)
                
                Text("Categorize your item for better organization")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Category", selection: $selectedCategory) {
                    Text("No Category").tag(Category?.none)
                    ForEach(categoryStore.categories) { category in
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 14, height: 14)
                            Text(category.name)
                        }
                        .tag(Optional(category))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
            
            Spacer(minLength: 40)
        }
    }
}

struct NavigationButtonsView: View {
    let currentStep: CreateItemView.CreateItemStep
    let photoData: Data?
    let name: String
    let selectedStorageSpace: StorageSpace?
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Primary Action Button
            Button(action: primaryAction) {
                Text(primaryButtonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!canProceed)
            
            // Secondary Actions
            HStack {
                if currentStep != .camera {
                    Button("Back", action: onBack)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentStep == .nameAndLocation {
                    Button("Skip Details", action: onSkip)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var primaryButtonText: String {
        switch currentStep {
        case .camera: return "Continue"
        case .nameAndLocation: return "Continue"
        case .descriptionAndCategories: return "Create Item"
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .camera:
            return photoData != nil
        case .nameAndLocation:
            return !name.isEmpty && selectedStorageSpace != nil
        case .descriptionAndCategories:
            return true
        }
    }
    
    private func primaryAction() {
        switch currentStep {
        case .descriptionAndCategories:
            onCreate()
        default:
            onNext()
        }
    }
}
