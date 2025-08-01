import SwiftUI

@main
struct LockupApp: App {
    @StateObject private var itemsStore = ItemsStore()
    @StateObject private var categoryStore = CategoryStore()
    @StateObject private var storageSpaceStore = StorageSpaceStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    CreateItemView(
                        itemsStore: itemsStore,
                        categoryStore: categoryStore,
                        storageSpaceStore: storageSpaceStore
                    )
                }
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }

                // In your TabView, update the ViewItemsView tab to include all three stores:
                ViewItemsView(
                    itemsStore: itemsStore,
                    categoryStore: categoryStore,
                    storageSpaceStore: storageSpaceStore
                )
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                NavigationView {
                    SearchView(
                        itemsStore: itemsStore,
                        categoryStore: categoryStore
                    )
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

                NavigationView {
                    StorageSpaceManagementView(storageSpaceStore: storageSpaceStore)
                }
                .tabItem {
                    Label("Spaces", systemImage: "cube.box")
                }
                
                NavigationView {
                    CategoryManagementView(categoryStore: categoryStore)
                }
                .tabItem {
                    Label("Categories", systemImage: "tag.circle")
                }
            }
        }
    }
}
