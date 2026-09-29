import SwiftUI
import UIKit

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

// Styling a Form section header so every section looks the same
extension View {
    func trackeenSectionHeader() -> some View {
        self
            .font(.forum(15))
            .foregroundStyle(Color.trackeenLightBrown)
            .textCase(nil)
    }
}

// Pushing Forum into the navigation bar and tab bar, which SwiftUI cannot style directly
enum TrackeenAppearance {
    static func apply() {
        let brown = UIColor(Color.trackeenBrown)
        let cream = UIColor(Color.trackeenCream)

        let navigationBar = UINavigationBarAppearance()
        navigationBar.configureWithOpaqueBackground()
        navigationBar.backgroundColor = cream
        navigationBar.shadowColor = .clear

        if let largeTitle = UIFont(name: "Forum", size: 34) {
            navigationBar.largeTitleTextAttributes = [.font: largeTitle, .foregroundColor: brown]
        }
        if let inlineTitle = UIFont(name: "Forum", size: 19) {
            navigationBar.titleTextAttributes = [.font: inlineTitle, .foregroundColor: brown]
        }

        UINavigationBar.appearance().standardAppearance = navigationBar
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBar
        UINavigationBar.appearance().compactAppearance = navigationBar

        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = cream

        if let tabLabel = UIFont(name: "Forum", size: 11) {
            let layouts = [
                tabBar.stackedLayoutAppearance,
                tabBar.inlineLayoutAppearance,
                tabBar.compactInlineLayoutAppearance
            ]
            for layout in layouts {
                layout.normal.titleTextAttributes = [.font: tabLabel]
                layout.selected.titleTextAttributes = [.font: tabLabel]
            }
        }

        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
    }
}
