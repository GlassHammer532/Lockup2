import SwiftUI

struct CategoryManagementView: View {
    @ObservedObject var categoryStore: CategoryStore
    @State private var newCategoryName = ""
    @State private var newCategoryColor = Color.blue

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Existing Categories")) {
                    ForEach(categoryStore.categories) { category in
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 20, height: 20)
                            Text(category.name)
                        }
                    }
                }
                Section(header: Text("Add Category")) {
                    TextField("Category Name", text: $newCategoryName)
                    ColorPicker("Color", selection: $newCategoryColor)
                    Button("Create Category") {
                        let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty &&
                            !categoryStore.categories.contains(where: { $0.name == trimmed }) {
                            let newCategory = Category(name: trimmed, color: newCategoryColor)
                            categoryStore.categories.append(newCategory)
                            newCategoryName = ""
                            newCategoryColor = .blue
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
    }
}
