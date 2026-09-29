import SwiftUI

// Standing in for a tab that is not built yet
struct ComingSoonView: View {
    var title: String
    var iconName: String

    var body: some View {
        ZStack {
            Color.trackeenCream

            VStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 44))
                    .foregroundStyle(Color.trackeenLightBrown)

                Text(title.uppercased())
                    .font(.forum(30))
                    .tracking(5)
                    .padding(.leading, 5)
                    .foregroundStyle(Color.trackeenBrown)

                Text("coming soon")
                    .font(.forum(16))
                    .foregroundStyle(Color.trackeenLightBrown)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ComingSoonView(title: "Log", iconName: "plus.circle")
}
