import SwiftUI
import SwiftData

struct LogDrinkView: View {
    @Environment(\.modelContext) private var modelContext

    // Holding what was logged today
    // This is fetched by hand rather than with @Query because @Query was not
    // refreshing the ring after a save.
    @State private var todayEntries: [CaffeineEntry] = []

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

    // Adding up everything logged today
    private var todayTotalMilligrams: Double {
        todayEntries.reduce(0) { $0 + $1.caffeineMilligrams }
    }

    // Reading today's drinks back out of the database
    private func refreshToday() {
        let startOfToday = Calendar.current.startOfDay(for: Date())

        let descriptor = FetchDescriptor<CaffeineEntry>(
            predicate: #Predicate { $0.dateConsumed >= startOfToday },
            sortBy: [SortDescriptor(\.dateConsumed, order: .reverse)]
        )

        todayEntries = (try? modelContext.fetch(descriptor)) ?? []
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
            .navigationTitle("Log a Drink")
            .toolbar {
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
            .sheet(isPresented: $showingSettings) {
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
            // Starting with a normal serving already filled in
            .onAppear {
                if amountText.isEmpty {
                    amountText = formattedAmount(chosenDrink.defaultAmount)
                }
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
                    limitMilligrams: dailyLimit
                )

                Text(todayDrinkCount == 1 ? "1 drink today" : "\(todayDrinkCount) drinks today")
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
        // Filling in a normal serving whenever the drink changes
        .onChange(of: chosenDrink) {
            amountText = formattedAmount(chosenDrink.defaultAmount)
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

    // Showing the serving without a trailing .0 on whole numbers
    private func formattedAmount(_ amount: Double) -> String {
        amount == amount.rounded()
            ? String(Int(amount))
            : String(format: "%.1f", amount)
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

#Preview {
    LogDrinkView()
        .modelContainer(for: CaffeineEntry.self, inMemory: true)
}
