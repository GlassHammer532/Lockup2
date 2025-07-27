import SwiftUI

struct SearchView: View {
    @ObservedObject var itemsStore: ItemsStore
    @ObservedObject var categoryStore: CategoryStore
    @State private var searchText = ""
    @State private var selectedCategory: Category?

    var filteredItems: [StorageItem] {
        itemsStore.items.filter { item in
            (searchText.isEmpty ||
             item.name.localizedCaseInsensitiveContains(searchText) ||
             (item.description?.localizedCaseInsensitiveContains(searchText) ?? false))
            && (selectedCategory == nil || item.categories.contains(where: { $0.id == selectedCategory!.id }))
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Search controls fixed at top
                    VStack(spacing: 12) {
                        TextField("Search by name or description", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        HStack {
                            Text("Category")
                            Spacer()
                            Picker("Category", selection: $selectedCategory) {
                                Text("All Categories").tag(Category?.none)
                                ForEach(categoryStore.categories) { category in
                                    HStack {
                                        Circle()
                                            .fill(category.color)
                                            .frame(width: 16, height: 16)
                                        Text(category.name)
                                    }
                                    .tag(Optional(category))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    
                    // Results list with swipe-to-delete
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemRowView(item: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Force inline toolbar to prevent large title space reservation
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // Force navigation bar configuration for iOS 18.5+
                if #available(iOS 18.0, *) {
                    setupNavigationBarForIOS18()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Fallback for older iOS versions
    }
    
    // MARK: - Delete Functionality
    private func deleteItems(at offsets: IndexSet) {
        // Get the actual items that correspond to the filtered results
        let itemsToDelete = offsets.map { filteredItems[$0] }
        
        // Remove items from the main items store
        for item in itemsToDelete {
            if let index = itemsStore.items.firstIndex(where: { $0.id == item.id }) {
                itemsStore.items.remove(at: index)
            }
        }
    }
    
    @available(iOS 18.0, *)
    private func setupNavigationBarForIOS18() {
        // Force navigation bar to inline mode to prevent large title space issues
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().prefersLargeTitles = false
    }
}

// MARK: - Item Row View
struct ItemRowView: View {
    @ObservedObject var item: StorageItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo thumbnail
            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.storageSpace.color)
                        .frame(width: 12, height: 12)
                    Text(item.storageSpace.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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
        }
        .padding(.vertical, 4)
    }
}
