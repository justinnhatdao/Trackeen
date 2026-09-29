import SwiftUI
import SwiftData

// Letting the user choose a drink from a list we style ourselves
// A plain Picker draws its own rows and ignores the custom font, so this
// replaces it with a List where every row is ours.
struct DrinkPickerView: View {
    @Binding var chosenDrink: ChosenDrink
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Holding the drinks the user added themselves
    // Fetched by hand for the same reason the Log screen does it, @Query was
    // not refreshing after a save.
    @State private var customDrinks: [CustomDrink] = []

    // Remembering the starred drinks between launches
    @AppStorage(FavoriteDrinks.storageKey) private var favoriteNamesText = ""

    @State private var showingAddDrink = false

    // Gathering every drink the user could pick, built in and custom
    private var everyDrink: [ChosenDrink] {
        DrinkType.allCases.map(ChosenDrink.init) + customDrinks.map(ChosenDrink.init)
    }

    // Listing the starred drinks, newest star last, skipping any that were deleted
    private var favoriteDrinks: [ChosenDrink] {
        FavoriteDrinks.names(in: favoriteNamesText)
            .compactMap { name in everyDrink.first { $0.name == name } }
    }

    var body: some View {
        List {
            if !favoriteDrinks.isEmpty {
                favoritesSection
            }

            addYourOwnSection

            if !customDrinks.isEmpty {
                myDrinksSection
            }

            ForEach(DrinkCategory.allCases, id: \.self) { category in
                Section {
                    ForEach(DrinkType.drinks(in: category)) { drink in
                        drinkRow(for: ChosenDrink(drink))
                    }
                } header: {
                    Text(category.rawValue).trackeenSectionHeader()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.trackeenCream)
        .navigationTitle("Drink")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshCustomDrinks()
        }
        .sheet(isPresented: $showingAddDrink) {
            AddCustomDrinkView { newDrink in
                choose(ChosenDrink(newDrink))
            }
        }
    }

    // Putting the starred drinks at the top where they are quick to reach
    private var favoritesSection: some View {
        Section {
            ForEach(favoriteDrinks, id: \.name) { drink in
                drinkRow(for: drink)
            }
        } header: {
            Text("Favorites").trackeenSectionHeader()
        }
    }

    // Offering the button that adds a drink we do not already have
    private var addYourOwnSection: some View {
        Section {
            Button {
                showingAddDrink = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add your own drink")
                        .font(.forum(18))
                }
                .foregroundStyle(Color.trackeenBrown)
            }
        }
    }

    // Listing the drinks the user made, with swipe to delete
    private var myDrinksSection: some View {
        Section {
            ForEach(customDrinks) { customDrink in
                drinkRow(for: ChosenDrink(customDrink))
            }
            .onDelete(perform: deleteCustomDrinks)
        } header: {
            Text("My Drinks").trackeenSectionHeader()
        }
    }

    // Showing one drink with its rate, a star to favorite it, and a checkmark
    // when it is the chosen one
    // The star is its own button so tapping it does not also pick the drink.
    private func drinkRow(for drink: ChosenDrink) -> some View {
        HStack(spacing: 12) {
            Button {
                toggleFavorite(drink)
            } label: {
                Image(systemName: isFavorite(drink) ? "star.fill" : "star")
                    .foregroundStyle(isFavorite(drink) ? .yellow : Color.trackeenLightBrown)
            }
            .buttonStyle(.borderless)

            VStack(alignment: .leading, spacing: 2) {
                Text(drink.name)
                    .font(.forum(18))
                    .foregroundStyle(Color.trackeenBrown)

                Text("about \(Int(drink.caffeinePerUnit.rounded())) mg per \(drink.unit.rawValue)")
                    .font(.forum(13))
                    .foregroundStyle(Color.trackeenLightBrown)
            }

            Spacer()

            if drink == chosenDrink {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.trackeenBrown)
            }
        }
        // Making the whole row tappable, not just the text
        .contentShape(Rectangle())
        .onTapGesture {
            choose(drink)
        }
    }

    private func isFavorite(_ drink: ChosenDrink) -> Bool {
        FavoriteDrinks.contains(drink.name, in: favoriteNamesText)
    }

    // Starring or unstarring a drink
    private func toggleFavorite(_ drink: ChosenDrink) {
        favoriteNamesText = FavoriteDrinks.toggling(drink.name, in: favoriteNamesText)
    }

    // Reading the user's own drinks back out of the database
    private func refreshCustomDrinks() {
        let descriptor = FetchDescriptor<CustomDrink>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )

        customDrinks = (try? modelContext.fetch(descriptor)) ?? []
    }

    // Picking a drink and going back to the Log screen
    private func choose(_ drink: ChosenDrink) {
        chosenDrink = drink
        dismiss()
    }

    // Removing a drink the user no longer wants
    private func deleteCustomDrinks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(customDrinks[index])
        }

        do {
            try modelContext.save()
        } catch {
            print("Could not delete the custom drink: \(error)")
        }

        refreshCustomDrinks()
    }
}

#Preview {
    NavigationStack {
        DrinkPickerView(chosenDrink: .constant(ChosenDrink(.brewedCoffee)))
            .modelContainer(for: CustomDrink.self, inMemory: true)
    }
}
