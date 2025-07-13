import Foundation
import SwiftUI

class CategoryStore: ObservableObject {
    @Published var categories: [Category] = [
        Category(name: "Fire Safety", color: .red),
        Category(name: "COSHH", color: .yellow),
        Category(name: "Trip Hazard", color: .orange)
    ]
}
