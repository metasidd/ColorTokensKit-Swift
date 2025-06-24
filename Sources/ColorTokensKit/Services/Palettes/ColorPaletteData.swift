import Foundation

struct ColorPaletteData: Codable {
    private var palettes: [String: [String: String]]

    // Keep public as it's the API surface
    var colorRamps: [ColorRamp] {
        // Sort by name to ensure consistent ordering
        palettes.sorted(by: { $0.key < $1.key }).map { name, stops in
            ColorRamp(
                name: name,
                stops: stops.mapValues { LCHColor(lchString: $0) }
            )
        }
    }

    public init(from decoder: Decoder) throws {
        // Decode the top-level dictionary directly
        let container = try decoder.singleValueContainer()
        palettes = try container.decode([String: [String: String]].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(palettes)
    }
}

public enum ColorRampLoader {
    // Cache the loaded palettes
    private static var cachedPalettes: ColorPaletteData?

    static func loadColorRamps() -> ColorPaletteData? {
        // Return cached version if available
        if let cached = cachedPalettes {
            return cached
        }

        guard let url = Bundle.module.url(forResource: "ColorPalettes", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            print("Failed to load ColorPalettes.json")
            return nil
        }

        do {
            let palettes = try JSONDecoder().decode(ColorPaletteData.self, from: data)
            cachedPalettes = palettes // Cache the loaded palettes
            return palettes
        } catch {
            print("Failed to decode ColorPalettes.json: \(error)")
            return nil
        }
    }
}
