import SwiftUI

// Keeping every color in one place so all the screens match
extension Color {
    static let trackeenCream = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let trackeenBrown = Color(red: 0.31, green: 0.20, blue: 0.13)
    static let trackeenLightBrown = Color(red: 0.55, green: 0.40, blue: 0.29)
}

// Using the bundled Forum font everywhere instead of retyping the name
extension Font {
    static func forum(_ size: CGFloat) -> Font {
        .custom("Forum", size: size)
    }
}
