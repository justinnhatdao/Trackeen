import Foundation

// Listing the time groupings for the spending chart
enum SpendingPeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }

    // Returning the calendar unit used for grouping
    var calendarComponent: Calendar.Component {
        switch self {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        }
    }

    // Returning how many bars or points to show
    var periodCount: Int {
        switch self {
        case .day: return 14
        case .week: return 8
        case .month: return 6
        }
    }

    // Describing the range under the total
    var rangeDescription: String {
        switch self {
        case .day: return "Last 14 days"
        case .week: return "Last 8 weeks"
        case .month: return "Last 6 months"
        }
    }
}

// Holding the total spent in one day, week, or month
struct SpendingTotal: Identifiable {
    let periodStart: Date
    let totalSpent: Double

    var id: Date { periodStart }
}
