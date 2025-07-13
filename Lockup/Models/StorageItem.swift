import Foundation

class StorageItem: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String
    @Published var photoData: Data?
    @Published var positionX: Int
    @Published var positionY: Int
    @Published var positionZ: Int
    @Published var description: String?
    @Published var categories: [Category]
    @Published var storageSpace: StorageSpace // Add this
    
    init(name: String, photoData: Data?, positionX: Int, positionY: Int, positionZ: Int, description: String? = nil, categories: [Category] = [], storageSpace: StorageSpace) {
        self.name = name
        self.photoData = photoData
        self.positionX = positionX
        self.positionY = positionY
        self.positionZ = positionZ
        self.description = description
        self.categories = categories
        self.storageSpace = storageSpace
    }
}
