import Foundation
import SwiftData

// Storing a drink the user added because it was not in the built in list
@Model
class CustomDrink {
    var name: String
    var unitRawValue: String
    var caffeinePerUnit: Double
    var defaultAmount: Double
    var dateAdded: Date

    init(name: String, unit: MeasurementUnit, caffeinePerUnit: Double, defaultAmount: Double, dateAdded: Date = Date()) {
        self.name = name
        self.unitRawValue = unit.rawValue
        self.caffeinePerUnit = caffeinePerUnit
        self.defaultAmount = defaultAmount
        self.dateAdded = dateAdded
    }

    // Turning the stored text back into a unit
    var unit: MeasurementUnit {
        MeasurementUnit(rawValue: unitRawValue) ?? .fluidOunces
    }
}
