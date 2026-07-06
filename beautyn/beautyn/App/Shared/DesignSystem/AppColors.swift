import SwiftUI

// MARK: - Color tokens extracted from Figma (file: Beautyn, node: Colors)

extension Color {
    enum App {

        // MARK: - Backgrounds
        static let backgroundLight  = Color(hex: "#FFFFFF")
        static let backgroundDark   = Color(hex: "#161618")

        // MARK: - Grays
        static let black            = Color(hex: "#000000")
        static let text             = Color(hex: "#2D2D2D")
        static let gray             = Color(hex: "#575553")
        static let gray2            = Color(hex: "#898887")
        static let gray3            = Color(hex: "#C7C7CC")
        static let blueTransparency = Color(hex: "#A6B7C9").opacity(0.20)
        static let white            = Color(hex: "#FFFFFF")

        // MARK: - Brand / Accent
        static let red              = Color(hex: "#FA4655")
        static let sun              = Color(hex: "#F7DB58")

        // MARK: - Palette
        static let sand             = Color(hex: "#FAF3D2")
        static let oliveDeep        = Color(hex: "#4C513A")
        static let sage             = Color(hex: "#D0DEAD")
        static let mauveVeil        = Color(hex: "#B76AB4")
        static let softBlush        = Color(hex: "#FADBFA")
        static let sageSkin         = Color(hex: "#A6B7C9")
        static let fogGrey          = Color(hex: "#C5D0D2")

        // MARK: - Browns / Beiges
        static let brown1           = Color(hex: "#5A483A")
        static let brown2           = Color(hex: "#907064")
        static let beige1           = Color(hex: "#B7A080")
        static let beige2           = Color(hex: "#EFE8D8")

        // MARK: - Semantic aliases
        static let primary          = red
        static let accent           = sun
        static let background       = Color(.systemBackground)   // adapts light/dark
        static let surface          = Color(.secondarySystemBackground)
        static let onBackground     = Color(.label)
        static let onSurface        = Color(.label)
        static let secondary        = Color(.secondaryLabel)
        static let separator        = Color(.separator)
        static let error            = red
        static let success          = sage
        static let warning          = sun
    }
}

// MARK: - Hex initialiser

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
