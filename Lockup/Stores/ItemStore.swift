import Foundation

class ItemsStore: ObservableObject {
    @Published var items: [StorageItem] = []
}
