import SwiftUI

struct StorageSpaceManagementView: View {
    @ObservedObject var storageSpaceStore: StorageSpaceStore
    @State private var newSpaceName = ""
    @State private var newSpaceWidth = 2
    @State private var newSpaceHeight = 3
    @State private var newSpaceDepth = 2
    @State private var newSpaceColor = Color.blue
    @State private var showingCreateSpace = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(storageSpaceStore.storageSpaces) { space in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Circle()
                                    .fill(space.color)
                                    .frame(width: 12, height: 12)
                                Text(space.name)
                                    .font(.headline)
                                Spacer()
                                Text("\(space.width)×\(space.height)×\(space.depth)m")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("Volume: \(space.width * space.height * space.depth) cubic meters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: deleteSpaces)
                } header: {
                    Text("Existing Storage Spaces")
                }
            }
            .navigationTitle("Storage Spaces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingCreateSpace = true
                    }
                }
            }
            .sheet(isPresented: $showingCreateSpace) {
                CreateStorageSpaceView(storageSpaceStore: storageSpaceStore)
            }
        }
    }
    
    func deleteSpaces(offsets: IndexSet) {
        storageSpaceStore.storageSpaces.remove(atOffsets: offsets)
    }
}

struct CreateStorageSpaceView: View {
    @ObservedObject var storageSpaceStore: StorageSpaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var width = 2
    @State private var height = 3
    @State private var depth = 2
    @State private var color = Color.blue
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Storage Space Name", text: $name)
                    ColorPicker("Color", selection: $color)
                } header: {
                    Text("Basic Info")
                }
                
                Section {
                    Stepper("Width: \(width)m", value: $width, in: 1...10)
                    Stepper("Height: \(height)m", value: $height, in: 1...10)
                    Stepper("Depth: \(depth)m", value: $depth, in: 1...10)
                    
                    Text("Total Volume: \(width * height * depth) cubic meters")
                        .foregroundColor(.secondary)
                } header: {
                    Text("Dimensions (meters)")
                }
                
                Section {
                    VStack {
                        Text("Grid Preview (\(width)×\(depth))")
                            .font(.caption)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: width), spacing: 2) {
                            ForEach(0..<(width * depth), id: \.self) { index in
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(height: 40)
                                    .overlay(
                                        Text("[\(index % width),\(index / width)]")
                                            .font(.caption2)
                                    )
                            }
                        }
                        .id(depth) // Force recreation when depth changes

                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("New Storage Space")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newSpace = StorageSpace(
                            name: name,
                            width: width,
                            height: height,
                            depth: depth,
                            color: color
                        )
                        storageSpaceStore.storageSpaces.append(newSpace)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
//Just for commit
