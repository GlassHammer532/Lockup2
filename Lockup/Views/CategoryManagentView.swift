import SwiftUI

struct CategoryManagementView: View {
    @ObservedObject var categoryStore: CategoryStore
    @State private var showingAddCategorySheet = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Categories")) {
                    ForEach(categoryStore.categories) { category in
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 24, height: 24)
                            Text(category.name)
                        }
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddCategorySheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCategorySheet) {
                CreateCategoryView(
                    categoryStore: categoryStore,
                    isPresented: $showingAddCategorySheet
                )
            }
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        categoryStore.categories.remove(atOffsets: offsets)
    }
}

struct CreateCategoryView: View {
    @ObservedObject var categoryStore: CategoryStore
    @Binding var isPresented: Bool
    @State private var categoryName: String = ""
    @State private var selectedColor: Color = .blue
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Name")) {
                    TextField("Enter name", text: $categoryName)
                        .autocapitalization(.words)
                }

                Section(header: Text("Color")) {
                    ColorPicker("Color", selection: $selectedColor)
                }

                Section(header: Text("Preview")) {
                    HStack {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 24, height: 24)
                        Text(categoryName.isEmpty ? "Category Name" : categoryName)
                            .foregroundColor(categoryName.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = categoryName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty &&
                            !categoryStore.categories.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
                            let newCategory = Category(name: trimmed, color: selectedColor)
                            categoryStore.categories.append(newCategory)
                            isPresented = false
                        } else {
                            showAlert = true
                        }
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Entry"),
                    message: Text("Please enter a unique, non-empty category name."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
