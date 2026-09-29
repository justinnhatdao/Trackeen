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

    @State private var showingAddDrink = false

    var body: some View {
        List {
            addYourOwnSection

            if !customDrinks.isEmpty {
                myDrinksSection
            }

            ForEach(DrinkCategory.allCases, id: \.self) { category in
                Section {
                    ForEach(DrinkType.drinks(in: category)) { drink in
                        let drinkOption = ChosenDrink(drink)

                        Button {
                            choose(drinkOption)
                        } label: {
                            drinkRow(for: drinkOption)
                        }
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
                Button {
                    choose(ChosenDrink(customDrink))
                } label: {
                    drinkRow(for: ChosenDrink(customDrink))
                }
            }
            .onDelete(perform: deleteCustomDrinks)
        } header: {
            Text("My Drinks").trackeenSectionHeader()
        }
    }

    // Showing one drink with its rate, and a checkmark when it is the chosen one
    private func drinkRow(for drink: ChosenDrink) -> some View {
        HStack {
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
