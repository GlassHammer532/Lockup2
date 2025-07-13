import SwiftUI

struct DynamicPositionPicker: View {
    @Binding var x: Int
    @Binding var y: Int
    @Binding var z: Int
    let storageSpace: StorageSpace
    
    var body: some View {
        VStack(spacing: 16) {
            Text("3D Position in \(storageSpace.name)")
                .font(.headline)
                .foregroundColor(storageSpace.color)
            
            // Y (Height) Controls
            VStack {
                Text("Height: \(y + 1) / \(storageSpace.height) meters")
                    .font(.subheadline)
                HStack {
                    Button("▲") {
                        if y < storageSpace.height - 1 { y += 1 }
                    }
                    .disabled(y >= storageSpace.height - 1)
                    
                    Text("Floor \(y + 1)")
                    
                    Button("▼") {
                        if y > 0 { y -= 1 }
                    }
                    .disabled(y <= 0)
                }
            }
            
            // X/Z Grid (Top-down view)
            VStack {
                Text("Position (Top View)")
                    .font(.subheadline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: storageSpace.width), spacing: 4) {
                    ForEach(0..<storageSpace.depth, id: \.self) { zi in
                        ForEach(0..<storageSpace.width, id: \.self) { xi in
                            Button(action: {
                                x = xi
                                z = zi
                            }) {
                                VStack {
                                    Text("[\(xi),\(zi)]")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                    Text("\(xi + 1)m,\(zi + 1)m")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .frame(minHeight: 44)
                                .background(x == xi && z == zi ? storageSpace.color : Color.gray.opacity(0.3))
                                .foregroundColor(x == xi && z == zi ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            Text("Selected: [\(x + 1)m, \(y + 1)m, \(z + 1)m]")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
        .onAppear {
            // Ensure position is within bounds
            if x >= storageSpace.width { x = storageSpace.width - 1 }
            if y >= storageSpace.height { y = storageSpace.height - 1 }
            if z >= storageSpace.depth { z = storageSpace.depth - 1 }
        }
    }
}
