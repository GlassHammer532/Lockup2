import SwiftUI
import UIKit

struct ItemDetailView: View {
    @ObservedObject var item: StorageItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Image or Placeholder
                if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 180)
                        .overlay(
                            Text("No Photo")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        )
                }

                Divider()

                // MARK: - General Info
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "cube.box.fill")
                            .foregroundColor(.accentColor)
                    }

                    HStack(spacing: 10) {
                        Circle()
                            .fill(item.storageSpace.color)
                            .frame(width: 14, height: 14)
                        Text("Storage Location: \(item.storageSpace.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("3D Position:  [\(item.positionX), \(item.positionY), \(item.positionZ)]")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // MARK: - Description
                if let desc = item.description, !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }

                // MARK: - Categories List
                if !item.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Categories")
                            .font(.headline)

                        ForEach(item.categories) { category in
                            CategoryLabelView(category: category)
                        }
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 8)
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryLabelView: View {
    let category: Category

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(category.color)
                .frame(width: 10, height: 10)
            Text(category.name)
                .font(.callout)
        }
        .padding(.vertical, 2)
    }
}
