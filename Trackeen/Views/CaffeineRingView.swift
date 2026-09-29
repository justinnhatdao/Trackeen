import SwiftUI

// Showing today's caffeine as a ring that fills up as the user drinks more
struct CaffeineRingView: View {
    var totalMilligrams: Double
    var limitMilligrams: Double

    private let ringWidth: CGFloat = 16

    // Filling the ring, stopping at full even when the user goes over
    private var progress: Double {
        guard limitMilligrams > 0 else { return 0 }
        return min(totalMilligrams / limitMilligrams, 1)
    }

    private var isOverLimit: Bool {
        limitMilligrams > 0 && totalMilligrams >= limitMilligrams
    }

    var body: some View {
        ZStack {
            // Drawing the empty track behind the ring
            Circle()
                .stroke(Color.trackeenBrown.opacity(0.15), lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    isOverLimit ? Color.red : Color.trackeenBrown,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                // Starting the ring at the top instead of the right side
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            VStack(spacing: 0) {
                Text("\(Int(totalMilligrams))")
                    .font(.forum(52))
                    .foregroundStyle(isOverLimit ? .red : Color.trackeenBrown)

                Text("of \(Int(limitMilligrams)) mg")
                    .font(.forum(16))
                    .foregroundStyle(Color.trackeenLightBrown)
            }
        }
        .frame(width: 180, height: 180)
    }
}

#Preview {
    VStack(spacing: 30) {
        CaffeineRingView(totalMilligrams: 0, limitMilligrams: 400)
        CaffeineRingView(totalMilligrams: 250, limitMilligrams: 400)
        CaffeineRingView(totalMilligrams: 430, limitMilligrams: 400)
    }
}
