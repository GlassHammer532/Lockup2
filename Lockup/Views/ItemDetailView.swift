import SwiftUI
import UIKit

struct ItemDetailView: View {
    @ObservedObject var item: StorageItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Image or placeholder
                if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .overlay(Text("No Photo").foregroundColor(.gray))
                }

                // Name
                Text("Name: \(item.name)")
                    .font(.headline)

                // Storage Space (non-optional)
                HStack {
                    Circle()
                        .fill(item.storageSpace.color)
                        .frame(width: 16, height: 16)
                    Text("Storage Space: \(item.storageSpace.name)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)

                // 3D Position
                Text("3D Position: [\(item.positionX), \(item.positionY), \(item.positionZ)]")

                // Description
                if let desc = item.description, !desc.isEmpty {
                    Text("Description: \(desc)")
                }

                // Categories
                if !item.categories.isEmpty {
                    Text("Categories:")
                    ForEach(item.categories) { category in
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 12, height: 12)
                            Text(category.name)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(item.name)
    }
}
