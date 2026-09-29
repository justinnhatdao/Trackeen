import SwiftUI
import SwiftData

// Letting the user add a drink that is not in the built in list
struct AddCustomDrinkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var unit: MeasurementUnit = .fluidOunces
    @State private var caffeineText = ""
    @State private var servingText = ""

    // Telling the Log screen to use the new drink straight away
    var onDrinkAdded: (CustomDrink) -> Void

    private var caffeineValue: Double {
        Double(caffeineText) ?? 0
    }

    private var servingValue: Double {
        Double(servingText) ?? 0
    }

    // Blocking Save until the drink has a name and a caffeine amount
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && caffeineValue > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .font(.forum(17))
                } header: {
                    Text("Drink name").trackeenSectionHeader()
                }

                Section {
                    Picker("Measured in", selection: $unit) {
                        ForEach(MeasurementUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .font(.forum(17))

                    HStack {
                        TextField("0", text: $caffeineText)
                            .keyboardType(.decimalPad)
                            .font(.forum(17))

                        Text("mg per \(unit.rawValue)")
                            .font(.forum(17))
                            .foregroundStyle(Color.trackeenLightBrown)
                    }
                } header: {
                    Text("Caffeine").trackeenSectionHeader()
                } footer: {
                    Text("Check the label. If it lists caffeine for the whole can or bottle, divide that by its size to get the amount per \(unit.rawValue).")
                        .font(.footnote)
                }

                Section {
                    HStack {
                        TextField("\(Int(defaultServingGuess))", text: $servingText)
                            .keyboardType(.decimalPad)
                            .font(.forum(17))

                        Text(unit.rawValue)
                            .font(.forum(17))
                            .foregroundStyle(Color.trackeenLightBrown)
                    }
                } header: {
                    Text("Usual serving").trackeenSectionHeader()
                } footer: {
                    Text("This is what the amount field fills in when you pick this drink. Leave it blank to use \(Int(defaultServingGuess)).")
                        .font(.footnote)
                }

                if caffeineValue > 0 {
                    Section {
                        Text("One serving comes to \(Int((servingValue > 0 ? servingValue : defaultServingGuess) * caffeineValue)) mg")
                            .font(.forum(17))
                            .foregroundStyle(Color.trackeenLightBrown)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.trackeenCream)
            .navigationTitle("New Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.forum(17))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCustomDrink() }
                        .font(.forum(17))
                        .disabled(!canSave)
                }
            }
        }
    }

    // Guessing a sensible serving based on how the drink is measured
    private var defaultServingGuess: Double {
        switch unit {
        case .fluidOunces: return 8
        case .grams: return 2
        case .pills: return 1
        }
    }

    // Saving the new drink and handing it back to the Log screen
    private func saveCustomDrink() {
        let newDrink = CustomDrink(
            name: name.trimmingCharacters(in: .whitespaces),
            unit: unit,
            caffeinePerUnit: caffeineValue,
            defaultAmount: servingValue > 0 ? servingValue : defaultServingGuess
        )
        modelContext.insert(newDrink)

        // Writing it to disk so it shows up in the list right away
        do {
            try modelContext.save()
        } catch {
            print("Could not save the custom drink: \(error)")
        }

        onDrinkAdded(newDrink)
        dismiss()
    }
}

#Preview {
    AddCustomDrinkView(onDrinkAdded: { _ in })
        .modelContainer(for: CustomDrink.self, inMemory: true)
}
