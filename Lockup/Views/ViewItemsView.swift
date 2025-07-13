import SwiftUI
import UIKit

struct ViewItemsView: View {
    @ObservedObject var itemsStore: ItemsStore
    var body: some View {
        NavigationView {
            List {
                ForEach(itemsStore.items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        HStack {
                            if let data = item.photoData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(6)
                            }
                            VStack(alignment: .leading) {
                                Text(item.name).bold()
                                Text("Pos: [\(item.positionX),\(item.positionY),\(item.positionZ)]")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if !item.categories.isEmpty {
                                    HStack {
                                        ForEach(item.categories.prefix(3)) { category in
                                            HStack {
                                                Circle()
                                                    .fill(category.color)
                                                    .frame(width: 8, height: 8)
                                                Text(category.name)
                                                    .font(.caption2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("View Items")
        }
    }
}
