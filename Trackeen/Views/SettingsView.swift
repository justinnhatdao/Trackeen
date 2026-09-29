import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Remembering the user's own daily limit between app launches
    @AppStorage(CaffeineGuidelines.dailyLimitStorageKey)
    private var dailyLimit = CaffeineGuidelines.defaultDailyLimitMilligrams

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("\(Int(dailyLimit)) mg")
                            .font(.forum(32))
                            .foregroundStyle(Color.trackeenBrown)

                        Spacer()

                        // Nudging the limit up or down in small steps
                        Stepper("Daily limit", value: $dailyLimit, in: 50...1000, step: 25)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)

                    Button("Reset to 400 mg") {
                        dailyLimit = CaffeineGuidelines.defaultDailyLimitMilligrams
                    }
                    .font(.forum(17))
                } header: {
                    Text("Daily caffeine limit").trackeenSectionHeader()
                } footer: {
                    Text("The FDA and Mayo Clinic put 400 mg a day as safe for most healthy adults. Lower it if caffeine hits you harder, or if you are pregnant or on medication.")
                        .font(.footnote)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.trackeenCream)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.forum(17))
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
