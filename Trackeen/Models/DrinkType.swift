import Foundation

// Listing how a drink type gets measured
enum MeasurementUnit: String, CaseIterable, Identifiable {
    case fluidOunces = "fl oz"
    case grams = "g"
    case pills = "pills"

    var id: String { rawValue }
}

// Grouping drink types for a sectioned picker
enum DrinkCategory: String, CaseIterable {
    case coffee = "Coffee"
    case tea = "Tea"
    case sodaAndEnergy = "Soda & Energy"
    case powders = "Powders"
    case other = "Other"
}

// Listing the general drink types the user can pick from
enum DrinkType: String, CaseIterable, Identifiable {
    // Coffee
    case brewedCoffee = "Brewed Coffee"
    case coldBrew = "Cold Brew"
    case espresso = "Espresso"
    case latte = "Latte / Cappuccino"
    case decafCoffee = "Decaf Coffee"

    // Tea
    case blackTea = "Black Tea"
    case greenTea = "Green Tea"
    case oolongTea = "Oolong Tea"
    case chaiLatte = "Chai Latte"
    case yerbaMate = "Yerba Mate"

    // Soda and energy
    case cola = "Cola"
    case dietCola = "Diet Cola"
    case citrusSoda = "Citrus Soda (Mountain Dew style)"
    case energyDrink = "Energy Drink"

    // Powders
    case matchaPowder = "Matcha Powder"
    case instantCoffee = "Instant Coffee"
    case groundCoffee = "Ground Coffee (home brew)"

    // Other
    case darkChocolate = "Dark Chocolate"
    case caffeinePill = "Caffeine Pill"

    var id: String { rawValue }

    // Returning which category the drink belongs to
    var category: DrinkCategory {
        switch self {
        case .brewedCoffee, .coldBrew, .espresso, .latte, .decafCoffee:
            return .coffee
        case .blackTea, .greenTea, .oolongTea, .chaiLatte, .yerbaMate:
            return .tea
        case .cola, .dietCola, .citrusSoda, .energyDrink:
            return .sodaAndEnergy
        case .matchaPowder, .instantCoffee, .groundCoffee:
            return .powders
        case .darkChocolate, .caffeinePill:
            return .other
        }
    }

    // Returning the unit the user enters for this drink
    var unit: MeasurementUnit {
        switch self {
        case .matchaPowder, .instantCoffee, .groundCoffee, .darkChocolate:
            return .grams
        case .caffeinePill:
            return .pills
        default:
            return .fluidOunces
        }
    }

    // Returning approximate caffeine in milligrams per one unit
    //
    // Every rate below is a published serving divided down to one unit, and the
    // source is on the same line. Caffeine really does vary with the bean, the
    // brew time, and the brand, so these are close estimates and not exact.
    // Lines marked "estimate" had no single published figure to work from.
    var caffeinePerUnit: Double {
        switch self {
        // Coffee
        case .brewedCoffee: return 20.4     // Jitterliss coffee: 163 mg per 8 fl oz
        case .coldBrew: return 12.8         // Jitterliss Starbucks cold brew: 205 mg per 16 fl oz
        case .espresso: return 51.3         // Jitterliss espresso shot: 77 mg per 1.5 fl oz
        case .latte: return 9.6             // Jitterliss latte: 154 mg per 16 fl oz
        case .decafCoffee: return 0.75      // Jitterliss decaf coffee: 6 mg per 8 fl oz

        // Tea
        case .blackTea: return 5.25         // Jitterliss black tea: 42 mg per 8 fl oz
        case .greenTea: return 2.25         // Jitterliss green tea: 18 mg per 8 fl oz
        case .oolongTea: return 4.6         // Jitterliss oolong tea: 37 mg per 8 fl oz
        case .chaiLatte: return 6.25        // Jitterliss chai tea: 50 mg per 8 fl oz
        case .yerbaMate: return 5.0         // Jitterliss yerba mate: 40 mg per 8 fl oz

        // Soda and energy
        case .cola: return 2.83             // Jitterliss Coca-Cola Classic: 34 mg per 12 fl oz
        case .dietCola: return 3.83         // Jitterliss Diet Coke: 46 mg per 12 fl oz
        case .citrusSoda: return 4.5        // Jitterliss Mountain Dew: 54 mg per 12 fl oz
        case .energyDrink: return 10.0      // Jitterliss Monster and Rockstar: 160 mg per 16 fl oz

        // Powders, measured by weight rather than volume
        case .matchaPowder: return 32.0     // Jitterliss matcha tea: 64 mg per 8 fl oz cup, about 2 g of powder
        case .instantCoffee: return 31.7    // Jitterliss instant coffee: 57 mg per 8 fl oz cup, about 1.8 g
        case .groundCoffee: return 10.9     // worked back from Jitterliss coffee, 163 mg from about 15 g of grounds

        // Other
        case .darkChocolate: return 0.8     // not on Jitterliss, 70 to 85 percent cocoa is about 80 mg per 100 g
        case .caffeinePill: return 200.0    // Jitterliss ProLab caffeine tablets: 200 mg per serving
        }
    }

    // Returning a normal serving so the amount field starts filled in
    var defaultAmount: Double {
        switch self {
        case .espresso: return 1.5
        case .latte: return 16
        case .chaiLatte: return 12
        case .cola, .dietCola, .citrusSoda: return 12
        case .energyDrink: return 16
        case .matchaPowder, .instantCoffee: return 2
        case .groundCoffee: return 18
        case .darkChocolate: return 30
        case .caffeinePill: return 1
        default: return 8
        }
    }

    // Calculating total caffeine for the amount entered
    func caffeineAmount(for amount: Double) -> Double {
        return caffeinePerUnit * amount
    }

    // Getting all drink types in one category
    static func drinks(in category: DrinkCategory) -> [DrinkType] {
        return allCases.filter { $0.category == category }
    }
}

// Holding the daily guideline the user starts with
// The FDA and Mayo Clinic both put 400 mg a day as safe for most healthy adults.
// The user can change their own limit in Settings.
enum CaffeineGuidelines {
    static let defaultDailyLimitMilligrams = 400.0

    // Naming the stored setting so every screen reads the same value
    static let dailyLimitStorageKey = "dailyLimitMilligrams"
}
