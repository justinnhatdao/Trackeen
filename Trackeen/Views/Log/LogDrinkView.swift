import SwiftUI
import SwiftData

struct LogDrinkView: View {
    @Environment(\.modelContext) private var modelContext

    // Holding what was logged today
    // This is fetched by hand rather than with @Query because @Query was not
    // refreshing the ring after a save.
    @State private var todayEntries: [CaffeineEntry] = []

    // Counting every saved drink, not just today's, so a date problem is obvious
    @State private var totalSavedCount = 0

    // Reading the limit the user set in Settings
    @AppStorage(CaffeineGuidelines.dailyLimitStorageKey)
    private var dailyLimit = CaffeineGuidelines.defaultDailyLimitMilligrams

    @State private var chosenDrink = ChosenDrink(.brewedCoffee)
    @State private var amountText = ""
    @State private var priceText = ""
    @State private var showingSavedMessage = false
    @State private var showingSettings = false
    @State private var saveErrorMessage: String?

    // Letting the user dismiss the number keyboard
    @FocusState private var isTypingNumbers: Bool

    // Turning the typed amount into a number
    private var amountValue: Double {
        Double(amountText) ?? 0
    }

    // Turning the typed price into a number
    private var priceValue: Double {
        Double(priceText) ?? 0
    }

    // Working out the caffeine for what the user entered
    private var caffeinePreview: Double {
        chosenDrink.caffeineAmount(for: amountValue)
    }

    // Falling back to the default if the stored limit ever reads as zero
    private var effectiveDailyLimit: Double {
        dailyLimit > 0 ? dailyLimit : CaffeineGuidelines.defaultDailyLimitMilligrams
    }

    // Adding up everything logged today
    private var todayTotalMilligrams: Double {
        todayEntries.reduce(0) { $0 + $1.caffeineMilligrams }
    }

    // Reading today's drinks back out of the database
    // Everything is fetched and then filtered in Swift on purpose. A #Predicate
    // that fails throws at fetch time, and swallowing that error looks exactly
    // like having no drinks, which is what hid this bug before.
    private func refreshToday() {
        let descriptor = FetchDescriptor<CaffeineEntry>(
            sortBy: [SortDescriptor(\.dateConsumed, order: .reverse)]
        )

        do {
            let everyEntry = try modelContext.fetch(descriptor)
            let calendar = Calendar.current
            totalSavedCount = everyEntry.count
            todayEntries = everyEntry.filter { calendar.isDateInToday($0.dateConsumed) }
        } catch {
            todayEntries = []
            totalSavedCount = 0
            saveErrorMessage = "Could not read your drinks: \(error.localizedDescription)"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                todaySection
                drinkSection
                amountSection
                priceSection
                saveSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.trackeenCream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Showing the wordmark instead of a plain title
                ToolbarItem(placement: .principal) {
                    Text("TRACKEEN")
                        .font(.forum(24))
                        .tracking(5)
                        .padding(.leading, 5)
                        .foregroundStyle(Color.trackeenBrown)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(Color.trackeenBrown)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTypingNumbers = false
                    }
                    .font(.forum(17))
                }
            }
            .sheet(isPresented: $showingSettings, onDismiss: refreshToday) {
                SettingsView()
            }
            .alert("Drink saved", isPresented: $showingSavedMessage) {
                Button("OK", role: .cancel) { }
            }
            .alert("Could not save", isPresented: .constant(saveErrorMessage != nil)) {
                Button("OK", role: .cancel) { saveErrorMessage = nil }
            } message: {
                Text(saveErrorMessage ?? "")
            }
            .onAppear {
                refreshToday()
            }
        }
    }

    // Counting what was logged today so the user can see it landed
    private var todayDrinkCount: Int {
        todayEntries.count
    }

    // Showing today's total inside the ring
    private var todaySection: some View {
        Section {
            VStack(spacing: 8) {
                CaffeineRingView(
                    totalMilligrams: todayTotalMilligrams,
                    limitMilligrams: effectiveDailyLimit
                )

                Text("\(todayDrinkCount) today, \(totalSavedCount) saved in total")
                    .font(.forum(15))
                    .foregroundStyle(Color.trackeenLightBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .listRowBackground(Color.clear)
        }
    }

    // Letting the user pick a drink, grouped by category
    private var drinkSection: some View {
        Section {
            NavigationLink {
                DrinkPickerView(chosenDrink: $chosenDrink)
            } label: {
                HStack {
                    Text("Type")
                        .font(.forum(17))
                        .foregroundStyle(Color.trackeenBrown)

                    Spacer()

                    Text(chosenDrink.name)
                        .font(.forum(17))
                        .foregroundStyle(Color.trackeenLightBrown)
                }
            }
        } header: {
            Text("Drink").trackeenSectionHeader()
        }
    }

    // Taking the amount and showing the caffeine it works out to
    private var amountSection: some View {
        Section {
            HStack {
                TextField("0", text: $amountText)
                    .font(.forum(17))
                    .keyboardType(.decimalPad)
                    .focused($isTypingNumbers)

                Text(chosenDrink.unit.rawValue)
                    .font(.forum(17))
                    .foregroundStyle(Color.trackeenLightBrown)
            }

            Text("Caffeine: \(Int(caffeinePreview)) mg")
                .font(.forum(17))
                .foregroundStyle(Color.trackeenLightBrown)
        } header: {
            Text("Amount").trackeenSectionHeader()
        }
        // Clearing the amount when the drink changes, the unit changes with it
        .onChange(of: chosenDrink) {
            amountText = ""
        }
    }

    // Taking what the drink cost
    private var priceSection: some View {
        Section {
            HStack {
                Text("$")
                    .font(.forum(17))
                    .foregroundStyle(Color.trackeenLightBrown)

                TextField("0.00", text: $priceText)
                    .font(.forum(17))
                    .keyboardType(.decimalPad)
                    .focused($isTypingNumbers)
            }
        } header: {
            Text("Price").trackeenSectionHeader()
        }
    }

    // Saving the entry, greyed out until there is caffeine to save
    private var saveSection: some View {
        Section {
            Button("Save Drink") {
                saveDrink()
            }
            .font(.forum(19))
            .frame(maxWidth: .infinity)
            .disabled(caffeinePreview <= 0)

            // Saying why the button is greyed out instead of doing nothing silently
            if caffeinePreview <= 0 {
                Text("Enter an amount above to save this drink.")
                    .font(.forum(14))
                    .foregroundStyle(Color.trackeenLightBrown)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // Saving the entry, stamping it with the current time, and clearing the form
    private func saveDrink() {
        let newEntry = CaffeineEntry(
            drinkName: chosenDrink.name,
            amount: amountValue,
            unit: chosenDrink.unit.rawValue,
            caffeineMilligrams: caffeinePreview,
            pricePaid: priceValue,
            dateConsumed: Date()
        )
        modelContext.insert(newEntry)

        // Writing it to disk right away so the ring updates and the entry survives a restart
        do {
            try modelContext.save()
        } catch {
            // Telling the user instead of failing quietly
            saveErrorMessage = error.localizedDescription
            return
        }

        // Reading the new total straight back so the ring moves
        refreshToday()

        amountText = ""
        priceText = ""
        isTypingNumbers = false
        showingSavedMessage = true
    }
}

// Filling the preview with a couple of drinks so the ring is not empty
// Saving in the preview does not stick, the database here is throwaway.
// Run the app with Cmd+R to test saving for real.
#Preview {
    let container = try! ModelContainer(
        for: CaffeineEntry.self, CustomDrink.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    container.mainContext.insert(CaffeineEntry(
        drinkName: DrinkType.brewedCoffee.rawValue,
        amount: 8,
        unit: MeasurementUnit.fluidOunces.rawValue,
        caffeineMilligrams: DrinkType.brewedCoffee.caffeineAmount(for: 8),
        pricePaid: 3.50
    ))

    return LogDrinkView()
        .modelContainer(container)
}
