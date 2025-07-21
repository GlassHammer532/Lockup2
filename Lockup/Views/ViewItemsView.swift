import SwiftUI

struct ViewItemsView: View {
    @ObservedObject var itemsStore: ItemsStore
    @ObservedObject var categoryStore: CategoryStore
    @ObservedObject var storageSpaceStore: StorageSpaceStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Basic Inventory Counts Section
                    InventoryCountsSection(
                        items: itemsStore.items,
                        categories: categoryStore.categories,
                        storageSpaces: storageSpaceStore.storageSpaces
                    )
                    
                    Divider()
                    
                    // Category Distribution Section
                    CategoryDistributionSection(
                        items: itemsStore.items,
                        categories: categoryStore.categories
                    )
                    
                    Divider()
                    
                    // Storage Distribution Section
                    StorageDistributionSection(
                        items: itemsStore.items,
                        storageSpaces: storageSpaceStore.storageSpaces
                    )
                    
                    Divider()
                    
                    // Recently Added Items Section
                    RecentlyAddedSection(items: itemsStore.items)
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Statistics")
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

// MARK: - Section Components

struct InventoryCountsSection: View {
    let items: [StorageItem]
    let categories: [Category]
    let storageSpaces: [StorageSpace]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inventory Overview")
                .font(.title2)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(title: "Total Items", value: "\(items.count)", color: .gray)
                StatCard(title: "Categories", value: "\(categories.count)", color: .gray)
                StatCard(title: "Storage Spaces", value: "\(storageSpaces.count)", color: .gray)
                StatCard(title: "With Photos", value: "\(items.filter { $0.photoData != nil }.count)", color: .gray)
            }
        }
    }
}

struct CategoryDistributionSection: View {
    let items: [StorageItem]
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Distribution")
                .font(.title2)
                .bold()
            
            if items.isEmpty {
                Text("No items to display")
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                ForEach(categories) { category in
                    let count = items.filter { $0.categories.contains(category) }.count
                    let percentage = items.count > 0 ? Double(count) / Double(items.count) * 100 : 0
                    
                    CategoryRow(category: category, count: count, percentage: percentage)
                }
                
                // Items with no category
                let uncategorizedCount = items.filter { $0.categories.isEmpty }.count
                if uncategorizedCount > 0 {
                    let percentage = Double(uncategorizedCount) / Double(items.count) * 100
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 16, height: 16)
                        Text("Uncategorized")
                            .font(.body)
                        Spacer()
                        Text("\(uncategorizedCount)")
                            .bold()
                        Text("(\(String(format: "%.1f", percentage))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct StorageDistributionSection: View {
    let items: [StorageItem]
    let storageSpaces: [StorageSpace]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Storage Distribution")
                .font(.title2)
                .bold()
            
            if items.isEmpty {
                Text("No items to display")
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                ForEach(storageSpaces) { space in
                    let count = items.filter { $0.storageSpace.id == space.id }.count
                    let percentage = items.count > 0 ? Double(count) / Double(items.count) * 100 : 0
                    
                    StorageRow(storageSpace: space, count: count, percentage: percentage)
                }
            }
        }
    }
}

struct RecentlyAddedSection: View {
    let items: [StorageItem]
    
    // Since StorageItem doesn't have a dateAdded field, we'll use the last 10 items
    // as a proxy for "recently added" (assuming items are added in order)
    private var recentItems: [StorageItem] {
        Array(items.suffix(10).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Added")
                .font(.title2)
                .bold()
            
            if recentItems.isEmpty {
                Text("No items added yet")
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                ForEach(recentItems) { item in
                    RecentItemRow(item: item)
                }
            }
        }
    }
}

// MARK: - Helper Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CategoryRow: View {
    let category: Category
    let count: Int
    let percentage: Double
    
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 16, height: 16)
            Text(category.name)
                .font(.body)
            Spacer()
            Text("\(count)")
                .bold()
            Text("(\(String(format: "%.1f", percentage))%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(category.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StorageRow: View {
    let storageSpace: StorageSpace
    let count: Int
    let percentage: Double
    
    var body: some View {
        HStack {
            Circle()
                .fill(storageSpace.color)
                .frame(width: 16, height: 16)
            VStack(alignment: .leading) {
                Text(storageSpace.name)
                    .font(.body)
                Text("\(storageSpace.width)×\(storageSpace.height)×\(storageSpace.depth)m")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(count)")
                .bold()
            Text("(\(String(format: "%.1f", percentage))%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(storageSpace.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct RecentItemRow: View {
    let item: StorageItem
    
    var body: some View {
        HStack {
            // Photo thumbnail
            if let data = item.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .bold()
                Text(item.storageSpace.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !item.categories.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(item.categories.prefix(2)) { category in
                            Text(category.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(category.color.opacity(0.2))
                                .foregroundColor(category.color)
                                .cornerRadius(4)
                        }
                        if item.categories.count > 2 {
                            Text("+\(item.categories.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Spacer()
            Text("Pos: [\(item.positionX),\(item.positionY),\(item.positionZ)]")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
