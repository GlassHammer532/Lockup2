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
                    
                    // Results list
                    List(filteredItems) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            Text(item.name)
                        }
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
