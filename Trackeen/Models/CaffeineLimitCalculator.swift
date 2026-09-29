import Foundation

// Describing how sensitive the user is to caffeine
enum CaffeineSituation: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case sensitive = "Sensitive to caffeine"
    case pregnant = "Pregnant or breastfeeding"

    var id: String { rawValue }

    // Explaining the choice in the setup screen
    var explanation: String {
        switch self {
        case .normal:
            return "Caffeine affects you about like it affects most people."
        case .sensitive:
            return "Small amounts make you jittery, or keep you up at night."
        case .pregnant:
            return "Health guidance is stricter during pregnancy."
        }
    }
}

// Working out a daily caffeine limit from a few answers
//
// Based on the common guidance that healthy adults handle about 6 mg of
// caffeine per kilogram of body weight, capped at the 400 mg the FDA and EFSA
// both use. Pregnancy drops to 200 mg, which matches the American College of
// Obstetricians guidance. Under 18 is held to 100 mg.
// This is a starting point, not medical advice.
enum CaffeineLimitCalculator {
    static let milligramsPerKilogram = 6.0

    // Holding the FDA and EFSA figure. This is a guideline we warn about, not a
    // ceiling we force, so a heavier person still gets their full 6 mg per kg.
    static let fdaDailyGuideline = 400.0

    static let pregnancyLimit = 200.0
    static let teenagerCap = 100.0
    static let lowestLimit = 50.0
    static let highestLimit = 1000.0

    // Saying whether a limit sits above the published guidance
    static func isAboveGuideline(_ limit: Double) -> Bool {
        limit > fdaDailyGuideline
    }

    // Turning pounds into kilograms
    static func kilograms(fromPounds pounds: Double) -> Double {
        pounds * 0.453592
    }

    // Producing the recommended daily limit in milligrams
    static func recommendedLimit(weightKilograms: Double, age: Int, situation: CaffeineSituation) -> Double {
        // Pregnancy guidance replaces the weight calculation entirely
        if situation == .pregnant {
            return pregnancyLimit
        }

        // Letting body weight carry past 400, the setup screen warns about it
        var limit = milligramsPerKilogram * weightKilograms

        // Holding teenagers to a lower ceiling
        if age < 18 {
            limit = min(limit, teenagerCap)
        }

        // Halving it for people who react strongly to caffeine
        if situation == .sensitive {
            limit = limit / 2
        }

        return clampAndRound(limit)
    }

    // Keeping the number tidy and inside sensible bounds
    private static func clampAndRound(_ limit: Double) -> Double {
        let rounded = (limit / 25).rounded() * 25
        return min(max(rounded, lowestLimit), highestLimit)
    }
}
