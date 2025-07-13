import SwiftUI

struct Category: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var color: Color

    // Custom encoding/decoding for Color
    enum CodingKeys: String, CodingKey {
        case id, name, colorData
    }

    init(name: String, color: Color) {
        self.id = UUID()
        self.name = name
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        let colorData = try container.decode(Data.self, forKey: .colorData)
        if let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .blue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)

        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
    }
}
