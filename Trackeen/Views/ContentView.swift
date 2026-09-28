import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogDrinkView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            SpendingChartView()
                .tabItem {
                    Label("Spending", systemImage: "chart.bar")
                }

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
        }
        .tint(Color.trackeenBrown)
    }
}

#Preview {
    ContentView()
}
