import Foundation

// Holding whichever drink the user picked, built in or their own
// Both kinds carry the same few facts, so the Log screen only deals with this.
struct ChosenDrink: Hashable {
    var name: String
    var unit: MeasurementUnit
    var caffeinePerUnit: Double
    var defaultAmount: Double

    // Building one from a drink that ships with the app
    init(_ drinkType: DrinkType) {
        name = drinkType.rawValue
        unit = drinkType.unit
        caffeinePerUnit = drinkType.caffeinePerUnit
        defaultAmount = drinkType.defaultAmount
    }

    // Building one from a drink the user added themselves
    init(_ customDrink: CustomDrink) {
        name = customDrink.name
        unit = customDrink.unit
        caffeinePerUnit = customDrink.caffeinePerUnit
        defaultAmount = customDrink.defaultAmount
    }

    // Calculating total caffeine for the amount entered
    func caffeineAmount(for amount: Double) -> Double {
        caffeinePerUnit * amount
    }
}
