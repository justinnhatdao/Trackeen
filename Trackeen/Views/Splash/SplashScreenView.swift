import SwiftUI

struct SplashScreenView: View {
    // Sweeping the reveal across the text once the screen appears
    @State private var hasRevealed = false

    // Telling the app when the splash is finished
    var onFinished: () -> Void

    // Holding the letter spacing so the text can be re-centered by the same amount
    private let titleTracking: CGFloat = 8
    private let taglineTracking: CGFloat = 2

    var body: some View {
        ZStack {
            Color.trackeenCream

            VStack(spacing: 14) {
                Text("TRACKEEN")
                    .font(.forum(54))
                    .tracking(titleTracking)
                    // Balancing the gap tracking leaves after the last letter
                    .padding(.leading, titleTracking)

                Text("for your caffeine needs")
                    .font(.forum(19))
                    .tracking(taglineTracking)
                    .padding(.leading, taglineTracking)
            }
            .foregroundStyle(Color.trackeenBrown)
            .mask(revealMask)
        }
        .ignoresSafeArea()
        .task {
            // Starting the sweep, then waiting a beat before handing off
            withAnimation(.easeInOut(duration: 1.8)) {
                hasRevealed = true
            }
            try? await Task.sleep(for: .seconds(2.6))
            onFinished()
        }
    }

    // Wiping a soft edge from left to right over both lines at once
    private var revealMask: some View {
        GeometryReader { proxy in
            let sweepWidth = proxy.size.width * 2

            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.5),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: sweepWidth)
                .offset(x: hasRevealed ? 0 : -sweepWidth)
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
