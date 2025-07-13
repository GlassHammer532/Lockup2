import SwiftUI

struct StorageSpace: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var width: Int    // X dimension in meters
    var height: Int   // Y dimension in meters
    var depth: Int    // Z dimension in meters
    var color: Color

    // Primary initializer
    init(name: String, width: Int, height: Int, depth: Int, color: Color = .blue) {
        self.id = UUID()
        self.name = name
        self.width = width
        self.height = height
        self.depth = depth
        self.color = color
    }

    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, width, height, depth, colorData
    }

    // Decoder – initialize all let/var exactly once
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        depth = try container.decode(Int.self, forKey: .depth)

        let data = try container.decode(Data.self, forKey: .colorData)
        if let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            color = Color(uiColor)
        } else {
            color = .blue
        }
    }

    // Encoder – archive UIColor into Data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(depth, forKey: .depth)

        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
    }
}
