import SwiftUI

// MARK: - Aeonik Pro PostScript names

enum AeonikPro {
    static let air        = "AeonikProTRIAL-Air"
    static let thin       = "AeonikProTRIAL-Thin"
    static let light      = "AeonikProTRIAL-Light"
    static let regular    = "AeonikProTRIAL-Regular"
    static let medium     = "AeonikProTRIAL-Medium"
    static let semiBold   = "AeonikProTRIAL-SemiBold"
    static let bold       = "AeonikProTRIAL-Bold"
    static let black      = "AeonikProTRIAL-Black"
}

// MARK: - Typography scale extracted from Figma (file: Beautyn, node: Text Styles)
//
//  Name           Font                    Size  LineH  Tracking
//  Large Title    Bold                    36    38     0
//  Large Title    Medium                  34    38     +0.34
//  Title 1        Bold                    28    34     +0.33
//  Title 1        Medium                  28    34     +0.33
//  Title 2        Bold                    22    26     +0.32
//  Title 2        Medium                  22    26     +0.32
//  Title 3        SemiBold                20    24     -0.30
//  Headline       Medium                  17    22     0
//  Body           Regular                 17    22     -0.41
//  Callout        Regular                 16    22     -0.32
//  Subhead        Regular                 15    20     -0.24
//  Footnote       Regular                 13    18     0
//  Caption 1      Regular                 12    16     0
//  Caption 2      Regular                 11    13     +0.06

extension Font {
    enum App {
        // Display
        static let largeTitleBold   = Font.custom(AeonikPro.bold,    size: 36)
        static let largeTitleMedium = Font.custom(AeonikPro.medium,  size: 34)

        // Titles
        static let title1Bold       = Font.custom(AeonikPro.bold,    size: 28)
        static let title1Medium     = Font.custom(AeonikPro.medium,  size: 28)
        static let title2Bold       = Font.custom(AeonikPro.bold,    size: 22)
        static let title2Medium     = Font.custom(AeonikPro.medium,  size: 22)
        static let title3           = Font.custom(AeonikPro.semiBold, size: 20)

        // Body
        static let headline         = Font.custom(AeonikPro.medium,  size: 17)
        static let body             = Font.custom(AeonikPro.regular, size: 17)
        static let callout          = Font.custom(AeonikPro.regular, size: 16)
        static let subheadline      = Font.custom(AeonikPro.regular, size: 15)
        static let footnote         = Font.custom(AeonikPro.regular, size: 13)

        // Captions
        static let caption1         = Font.custom(AeonikPro.regular, size: 12)
        static let caption2         = Font.custom(AeonikPro.regular, size: 11)

        // Convenience shorthands
        static let largeTitle       = largeTitleBold
        static let title            = title1Bold
        static let title2           = title2Bold
        static let title3Medium     = Font.custom(AeonikPro.medium, size: 20)

        static func custom(_ postScriptName: String, size: CGFloat) -> Font {
            Font.custom(postScriptName, size: size)
        }
    }
}

// MARK: - Tracking (letter-spacing) constants from Figma

extension CGFloat {
    enum Tracking {
        static let largeTitleMedium: CGFloat  =  0.34
        static let title1:           CGFloat  =  0.33
        static let title2:           CGFloat  =  0.32
        static let title3:           CGFloat  = -0.30
        static let body:             CGFloat  = -0.41
        static let callout:          CGFloat  = -0.32
        static let subheadline:      CGFloat  = -0.24
        static let caption2:         CGFloat  =  0.06
    }
}

// MARK: - Line height helper

extension View {
    /// Applies Figma line height by using `.lineSpacing` approximation.
    func lineHeight(_ px: CGFloat, fontSize: CGFloat) -> some View {
        self.lineSpacing(px - fontSize)
    }
}
