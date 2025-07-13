import Foundation
import SwiftUI

class StorageSpaceStore: ObservableObject {
    @Published var storageSpaces: [StorageSpace] = [
        StorageSpace(name: "Small Closet", width: 2, height: 3, depth: 2, color: .blue),
        StorageSpace(name: "Garage", width: 4, height: 3, depth: 5, color: .green),
        StorageSpace(name: "Attic", width: 3, height: 2, depth: 3, color: .orange)
    ]
}
