import SwiftUI
import SwiftData

@main
struct TrackeenApp: App {
    // Showing the splash first, then the real app
    @State private var isShowingSplash = true

    init() {
        // Putting Forum into the navigation bar and tab bar before anything draws
        TrackeenAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashScreenView {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isShowingSplash = false
                    }
                }
            } else {
                ContentView()
            }
        }
        // Setting up the database that stores logged drinks and custom drinks
        .modelContainer(for: [CaffeineEntry.self, CustomDrink.self])
    }
}
