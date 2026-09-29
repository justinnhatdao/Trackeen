import Foundation

// Remembering which drinks the user starred
//
// Favourites are stored as one string of names separated by new lines, which
// is enough for a simple list and keeps it out of the database. Drinks are
// matched by name, so a built in drink and a custom drink work the same way.
enum FavoriteDrinks {
    static let storageKey = "favoriteDrinkNames"

    // Reading the saved names back out
    static func names(in storedText: String) -> [String] {
        storedText
            .split(separator: "\n")
            .map(String.init)
    }

    // Saying whether a drink is starred
    static func contains(_ name: String, in storedText: String) -> Bool {
        names(in: storedText).contains(name)
    }

    // Starring a drink, or unstarring it if it was already starred
    static func toggling(_ name: String, in storedText: String) -> String {
        var saved = names(in: storedText)

        if let existing = saved.firstIndex(of: name) {
            saved.remove(at: existing)
        } else {
            saved.append(name)
        }

        return saved.joined(separator: "\n")
    }
}
