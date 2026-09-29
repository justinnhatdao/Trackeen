import SwiftUI

// Saying what Trackeen is, what it is not, and where its numbers come from
struct AboutView: View {
    var body: some View {
        List {
            disclaimerSection
            privacySection
            caffeineSourcesSection
            limitSourcesSection
            creditsSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.trackeenCream)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Making clear this is a personal project, not a medical tool
    private var disclaimerSection: some View {
        Section {
            Text("Trackeen is a personal project made for fun. It is not a medical device and it is not medical advice.\n\nThe caffeine amounts are averages from public charts, so what you actually drink will differ. Nobody behind this app is liable for any decision you make based on it.\n\nIf you are pregnant, take medication, or have a heart condition, talk to a doctor about caffeine rather than trusting a number on a screen.")
                .font(.forum(15))
                .foregroundStyle(Color.trackeenBrown)
                .padding(.vertical, 4)
        } header: {
            Text("Please read").trackeenSectionHeader()
        }
    }

    // Saying where the data goes, which is nowhere
    private var privacySection: some View {
        Section {
            Text("Everything you log stays on this device. Trackeen has no account, no server, and no analytics, and it does not send your drinks, your weight, or your limit anywhere.\n\nDeleting the app deletes all of it.")
                .font(.forum(15))
                .foregroundStyle(Color.trackeenBrown)
                .padding(.vertical, 4)
        } header: {
            Text("Privacy").trackeenSectionHeader()
        }
    }

    // Listing where the per drink caffeine numbers came from
    private var caffeineSourcesSection: some View {
        Section {
            sourceLink(
                title: "Jitterliss caffeine list",
                detail: "The rate for nearly every drink in the app",
                address: "https://www.jitterliss.com/caffeinelist"
            )

            sourceLink(
                title: "Mayo Clinic caffeine chart",
                detail: "Cross checked the coffee and tea numbers",
                address: "https://www.mayoclinic.org/healthy-lifestyle/nutrition-and-healthy-eating/in-depth/caffeine/art-20049372"
            )

            sourceLink(
                title: "CSPI caffeine chart",
                detail: "Cross checked the soda and energy drink numbers",
                address: "https://www.cspi.org/caffeine-chart"
            )
        } header: {
            Text("Where the caffeine numbers come from").trackeenSectionHeader()
        } footer: {
            Text("Dark chocolate is the one drink not on these lists, and its estimate is marked as such in the code.")
                .font(.footnote)
        }
    }

    // Listing where the daily limit advice came from
    private var limitSourcesSection: some View {
        Section {
            sourceLink(
                title: "Coffee Craft Guide calculator",
                detail: "The 6 mg per kilogram of body weight rule",
                address: "https://www.coffeecraftguide.com/caffeine-calculator/"
            )

            sourceLink(
                title: "FDA on caffeine",
                detail: "400 mg a day for most healthy adults",
                address: "https://www.fda.gov/consumers/consumer-updates/spilling-beans-how-much-caffeine-too-much"
            )

            sourceLink(
                title: "Mayo Clinic, how much is too much",
                detail: "The same 400 mg figure, with context",
                address: "https://www.mayoclinic.org/healthy-lifestyle/nutrition-and-healthy-eating/in-depth/caffeine/art-20045678"
            )

            sourceLink(
                title: "ACOG on caffeine in pregnancy",
                detail: "The 200 mg figure used for pregnancy",
                address: "https://www.acog.org/womens-health/experts-and-stories/ask-acog/how-much-coffee-can-i-drink-while-pregnant"
            )
        } header: {
            Text("Where the daily limit comes from").trackeenSectionHeader()
        }
    }

    private var creditsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 2) {
                Text("Made by Justin Dao")
                    .font(.forum(17))
                    .foregroundStyle(Color.trackeenBrown)

                Text("Design and development")
                    .font(.forum(13))
                    .foregroundStyle(Color.trackeenLightBrown)
            }
            .padding(.vertical, 2)

            sourceLink(
                title: "Forum by Denis Masharov",
                detail: "The app's typeface, SIL Open Font License",
                address: "https://fonts.google.com/specimen/Forum"
            )
        } header: {
            Text("Credits").trackeenSectionHeader()
        }
    }

    // Showing one source as a tappable row
    private func sourceLink(title: String, detail: String, address: String) -> some View {
        Link(destination: URL(string: address)!) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.forum(17))
                        .foregroundStyle(Color.trackeenBrown)

                    Text(detail)
                        .font(.forum(13))
                        .foregroundStyle(Color.trackeenLightBrown)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.footnote)
                    .foregroundStyle(Color.trackeenLightBrown)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
