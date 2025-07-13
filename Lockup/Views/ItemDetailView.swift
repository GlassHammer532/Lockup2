import SwiftUI
import UIKit

struct ItemDetailView: View {
    @ObservedObject var item: StorageItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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

                Text("Name: \(item.name)").font(.headline)
                Text("3D Position: [\(item.positionX), \(item.positionY), \(item.positionZ)]")
                if let desc = item.description, !desc.isEmpty {
                    Text("Description: \(desc)")
                }
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
