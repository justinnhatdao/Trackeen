import SwiftUI
import SwiftData
import Charts

struct SpendingChartView: View {
    @Environment(\.modelContext) private var modelContext

    // Holding every drink ever logged
    // Fetched by hand rather than with @Query, same as the Log screen.
    @State private var allEntries: [CaffeineEntry] = []

    @State private var selectedPeriod: SpendingPeriod = .day

    // Tracking where the user is touching the chart
    @State private var scrubbedDate: Date?

    // Adding up spending for each recent period, including the empty ones so
    // the chart does not skip over days with no drinks
    private var spendingTotals: [SpendingTotal] {
        let calendar = Calendar.current
        let component = selectedPeriod.calendarComponent

        guard let currentPeriodStart = calendar.dateInterval(of: component, for: Date())?.start else {
            return []
        }

        var totals: [SpendingTotal] = []

        for stepsBack in (0..<selectedPeriod.periodCount).reversed() {
            guard let periodStart = calendar.date(byAdding: component, value: -stepsBack, to: currentPeriodStart),
                  let periodInterval = calendar.dateInterval(of: component, for: periodStart) else {
                continue
            }

            let totalSpent = allEntries
                .filter { $0.dateConsumed >= periodInterval.start && $0.dateConsumed < periodInterval.end }
                .reduce(0) { $0 + $1.pricePaid }

            totals.append(SpendingTotal(periodStart: periodStart, totalSpent: totalSpent))
        }

        return totals
    }

    // Finding the period nearest to where the user is touching
    private var scrubbedTotal: SpendingTotal? {
        guard let scrubbedDate else { return nil }

        return spendingTotals.min { first, second in
            let firstGap = abs(first.periodStart.timeIntervalSince(scrubbedDate))
            let secondGap = abs(second.periodStart.timeIntervalSince(scrubbedDate))
            return firstGap < secondGap
        }
    }

    // Adding up everything shown on the chart
    private var totalInRange: Double {
        spendingTotals.reduce(0) { $0 + $1.totalSpent }
    }

    private var averagePerPeriod: Double {
        guard !spendingTotals.isEmpty else { return 0 }
        return totalInRange / Double(spendingTotals.count)
    }

    private var highestSpend: Double {
        spendingTotals.map(\.totalSpent).max() ?? 0
    }

    private var hasAnySpending: Bool {
        totalInRange > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.trackeenCream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        totalHeader

                        if hasAnySpending {
                            chart
                            summaryRow
                        } else {
                            emptyState
                        }

                        periodPicker
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Spending")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                refreshEntries()
            }
        }
    }

    // Showing the touched period while scrubbing, and the range total otherwise
    private var totalHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(scrubbedTotal?.totalSpent ?? totalInRange, format: .currency(code: "USD"))
                .font(.forum(46))
                .foregroundStyle(Color.trackeenBrown)
                // Keeping the number from jumping around as it changes width
                .contentTransition(.numericText())

            if let scrubbedTotal {
                Text(scrubbedTotal.periodStart, format: headerDateFormat)
                    .font(.forum(16))
                    .foregroundStyle(Color.trackeenGreen)
            } else {
                Text(selectedPeriod.rangeDescription)
                    .font(.forum(16))
                    .foregroundStyle(Color.trackeenLightBrown)
            }
        }
        // Holding the row height steady so the chart does not shift
        .frame(height: 70, alignment: .top)
    }

    private var chart: some View {
        Chart {
            ForEach(spendingTotals) { total in
                // Filling under the line, faded out towards the bottom
                AreaMark(
                    x: .value("Period", total.periodStart, unit: selectedPeriod.calendarComponent),
                    y: .value("Spent", total.totalSpent)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.trackeenGreen.opacity(0.35), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Period", total.periodStart, unit: selectedPeriod.calendarComponent),
                    y: .value("Spent", total.totalSpent)
                )
                .foregroundStyle(Color.trackeenGreen)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
            }

            // Marking the spot the user is touching
            if let scrubbedTotal {
                RuleMark(
                    x: .value("Touched", scrubbedTotal.periodStart, unit: selectedPeriod.calendarComponent)
                )
                .foregroundStyle(Color.trackeenBrown.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(
                    x: .value("Touched", scrubbedTotal.periodStart, unit: selectedPeriod.calendarComponent),
                    y: .value("Spent", scrubbedTotal.totalSpent)
                )
                .foregroundStyle(Color.trackeenGreen)
                .symbolSize(140)
            }
        }
        .frame(height: 250)
        // Letting the user drag along the chart to read each period
        .chartXSelection(value: $scrubbedDate)
        // Giving a small tap each time the reading changes, like a dial
        .sensoryFeedback(.selection, trigger: scrubbedTotal?.periodStart)
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(Color.trackeenBrown.opacity(0.12))

                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                            .font(.forum(12))
                            .foregroundStyle(Color.trackeenLightBrown)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: axisDateFormat)
                            .font(.forum(12))
                            .foregroundStyle(Color.trackeenLightBrown)
                    }
                }
            }
        }
    }

    // Labelling the bottom axis to suit the period
    private var axisDateFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .day, .week:
            return .dateTime.month(.abbreviated).day()
        case .month:
            return .dateTime.month(.abbreviated)
        }
    }

    // Spelling the touched period out in full under the total
    private var headerDateFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .day:
            return .dateTime.weekday(.wide).month(.abbreviated).day()
        case .week:
            return .dateTime.month(.abbreviated).day()
        case .month:
            return .dateTime.month(.wide).year()
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            summaryTile(
                label: "Average per \(selectedPeriod.rawValue.lowercased())",
                amount: averagePerPeriod
            )

            summaryTile(
                label: "Most in one \(selectedPeriod.rawValue.lowercased())",
                amount: highestSpend
            )
        }
    }

    private func summaryTile(label: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(amount, format: .currency(code: "USD"))
                .font(.forum(24))
                .foregroundStyle(Color.trackeenBrown)

            Text(label)
                .font(.forum(13))
                .foregroundStyle(Color.trackeenLightBrown)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.trackeenBrown.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // Explaining the blank chart rather than showing a flat line
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(Color.trackeenLightBrown)

            Text("No spending yet")
                .font(.forum(22))
                .foregroundStyle(Color.trackeenBrown)

            Text("Add a price when you log a drink and it will show up here.")
                .font(.forum(15))
                .foregroundStyle(Color.trackeenLightBrown)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(SpendingPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        // Dropping the reading when the period changes, the old date is meaningless
        .onChange(of: selectedPeriod) {
            scrubbedDate = nil
        }
    }

    // Reading every drink back out of the database
    private func refreshEntries() {
        let descriptor = FetchDescriptor<CaffeineEntry>(
            sortBy: [SortDescriptor(\.dateConsumed)]
        )

        allEntries = (try? modelContext.fetch(descriptor)) ?? []
    }
}

#Preview {
    let container = try! ModelContainer(
        for: CaffeineEntry.self, CustomDrink.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Filling the preview with some coffee so the chart has shape
    for daysBack in 0..<12 {
        let date = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date())!
        container.mainContext.insert(CaffeineEntry(
            drinkName: DrinkType.brewedCoffee.rawValue,
            amount: 8,
            unit: MeasurementUnit.fluidOunces.rawValue,
            caffeineMilligrams: 163,
            pricePaid: Double(2 + daysBack % 5),
            dateConsumed: date
        ))
    }

    return SpendingChartView()
        .modelContainer(container)
}
