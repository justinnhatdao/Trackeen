import SwiftUI

@main
struct TrackeenApp: App {
    // Showing the splash first, then the real app
    @State private var isShowingSplash = true

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
    }
}
