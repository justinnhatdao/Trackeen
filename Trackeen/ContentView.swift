import SwiftUI

struct ContentView: View {
    var body: some View {
        // Showing a placeholder until the first feature lands
        VStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundStyle(.brown)

            Text("Trackeen")
                .font(.largeTitle.bold())

            Text("Caffeine tracker")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
