import Foundation
import SwiftData

// Storing one drink the user logged
@Model
class CaffeineEntry {
    var drinkName: String
    var amount: Double
    var unit: String
    var caffeineMilligrams: Double
    var pricePaid: Double = 0
    var dateConsumed: Date

    init(drinkName: String, amount: Double, unit: String, caffeineMilligrams: Double, pricePaid: Double = 0, dateConsumed: Date = Date()) {
        self.drinkName = drinkName
        self.amount = amount
        self.unit = unit
        self.caffeineMilligrams = caffeineMilligrams
        self.pricePaid = pricePaid
        self.dateConsumed = dateConsumed
    }
}
