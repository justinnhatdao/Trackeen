import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Asking before wiping anything
    @State private var confirmingClearToday = false
    @State private var confirmingDeleteAll = false

    // Remembering the user's own daily limit between app launches
    @AppStorage(CaffeineGuidelines.dailyLimitStorageKey)
    private var dailyLimit = CaffeineGuidelines.defaultDailyLimitMilligrams

    // Letting the user redo the first launch questions
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding = false

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

                    // Warning rather than blocking, the limit is the user's call
                    if CaffeineLimitCalculator.isAboveGuideline(dailyLimit) {
                        Label(
                            "Above the 400 mg the FDA suggests as a daily maximum for healthy adults.",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.forum(14))
                        .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Daily caffeine limit").trackeenSectionHeader()
                } footer: {
                    Text("The FDA and Mayo Clinic put 400 mg a day as safe for most healthy adults. Lower it if caffeine hits you harder, or if you are pregnant or on medication.")
                        .font(.footnote)
                }

                Section {
                    // Letting the setup questions run again without reinstalling
                    Button("Run setup again") {
                        hasFinishedOnboarding = false
                        dismiss()
                    }
                    .font(.forum(17))
                } footer: {
                    Text("Answers a few questions about your weight and age to suggest a limit.")
                        .font(.footnote)
                }

                trialsSection

                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About, privacy, and sources")
                            .font(.forum(17))
                            .foregroundStyle(Color.trackeenBrown)
                    }
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

    // Letting the user wipe drinks so they can test the app on a clean slate
    private var trialsSection: some View {
        Section {
            Button("Clear today's drinks", role: .destructive) {
                confirmingClearToday = true
            }
            .font(.forum(17))

            Button("Delete all drinks", role: .destructive) {
                confirmingDeleteAll = true
            }
            .font(.forum(17))
        } header: {
            Text("Start over").trackeenSectionHeader()
        } footer: {
            Text("Clearing today empties the ring but keeps your history. Deleting all removes every drink you have ever logged. Your own custom drinks are kept either way.")
                .font(.footnote)
        }
        .confirmationDialog(
            "Clear everything logged today?",
            isPresented: $confirmingClearToday,
            titleVisibility: .visible
        ) {
            Button("Clear today", role: .destructive) { clearTodaysDrinks() }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog(
            "Delete every drink you have logged?",
            isPresented: $confirmingDeleteAll,
            titleVisibility: .visible
        ) {
            Button("Delete all", role: .destructive) { deleteAllDrinks() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone.")
        }
    }

    // Removing only the drinks from today, leaving the rest of the history
    private func clearTodaysDrinks() {
        let calendar = Calendar.current
        removeDrinks { calendar.isDateInToday($0.dateConsumed) }
    }

    // Removing every drink ever logged
    private func deleteAllDrinks() {
        removeDrinks { _ in true }
    }

    // Deleting whichever drinks match, then saving
    private func removeDrinks(matching shouldDelete: (CaffeineEntry) -> Bool) {
        do {
            let everyEntry = try modelContext.fetch(FetchDescriptor<CaffeineEntry>())

            for entry in everyEntry where shouldDelete(entry) {
                modelContext.delete(entry)
            }

            try modelContext.save()
        } catch {
            print("Could not clear the drinks: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [CaffeineEntry.self, CustomDrink.self], inMemory: true)
}
