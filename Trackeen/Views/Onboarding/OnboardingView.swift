import SwiftUI

// Asking a few questions on first launch to work out a daily caffeine limit
struct OnboardingView: View {
    // Remembering the limit the rest of the app reads
    @AppStorage(CaffeineGuidelines.dailyLimitStorageKey)
    private var dailyLimit = CaffeineGuidelines.defaultDailyLimitMilligrams

    // Telling the app that setup is finished, so it never shows again
    var onFinished: () -> Void

    @State private var weightText = ""
    @State private var usesPounds = true
    @State private var ageText = ""
    @State private var situation: CaffeineSituation = .normal

    @FocusState private var isTypingNumbers: Bool

    private var weightValue: Double {
        Double(weightText) ?? 0
    }

    private var ageValue: Int {
        Int(ageText) ?? 0
    }

    // Holding off on a suggestion until both numbers are filled in
    private var hasEnoughAnswers: Bool {
        weightValue > 0 && ageValue > 0
    }

    // Working out the suggested limit from the answers so far
    private var suggestedLimit: Double {
        let kilograms = usesPounds
            ? CaffeineLimitCalculator.kilograms(fromPounds: weightValue)
            : weightValue

        return CaffeineLimitCalculator.recommendedLimit(
            weightKilograms: kilograms,
            age: ageValue,
            situation: situation
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                introSection
                weightSection
                ageSection
                situationSection

                if hasEnoughAnswers {
                    resultSection
                }

                buttonsSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.trackeenCream)
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isTypingNumbers = false }
                        .font(.forum(17))
                }
            }
        }
    }

    // Saying what the questions are for
    private var introSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("A few quick questions")
                    .font(.forum(24))
                    .foregroundStyle(Color.trackeenBrown)

                Text("These set your daily caffeine limit. You can change it any time in Settings, or skip and use the standard 400 mg.")
                    .font(.forum(15))
                    .foregroundStyle(Color.trackeenLightBrown)
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.clear)
        }
    }

    private var weightSection: some View {
        Section {
            HStack {
                TextField("0", text: $weightText)
                    .font(.forum(17))
                    .keyboardType(.decimalPad)
                    .focused($isTypingNumbers)

                Picker("Units", selection: $usesPounds) {
                    Text("lb").tag(true)
                    Text("kg").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 110)
            }
        } header: {
            Text("Your weight").trackeenSectionHeader()
        } footer: {
            Text("Caffeine tolerance scales with body weight, about 6 mg per kilogram.")
                .font(.footnote)
        }
    }

    private var ageSection: some View {
        Section {
            TextField("0", text: $ageText)
                .font(.forum(17))
                .keyboardType(.numberPad)
                .focused($isTypingNumbers)
        } header: {
            Text("Your age").trackeenSectionHeader()
        }
    }

    private var situationSection: some View {
        Section {
            ForEach(CaffeineSituation.allCases) { option in
                Button {
                    situation = option
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.rawValue)
                                .font(.forum(17))
                                .foregroundStyle(Color.trackeenBrown)

                            Text(option.explanation)
                                .font(.forum(13))
                                .foregroundStyle(Color.trackeenLightBrown)
                        }

                        Spacer()

                        if option == situation {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.trackeenBrown)
                        }
                    }
                }
            }
        } header: {
            Text("How caffeine treats you").trackeenSectionHeader()
        }
    }

    // Showing what the answers work out to
    private var resultSection: some View {
        Section {
            VStack(spacing: 4) {
                Text("\(Int(suggestedLimit)) mg")
                    .font(.forum(40))
                    .foregroundStyle(Color.trackeenBrown)

                Text("suggested daily limit")
                    .font(.forum(15))
                    .foregroundStyle(Color.trackeenLightBrown)

                // Warning when body weight pushes the number past the guideline
                if CaffeineLimitCalculator.isAboveGuideline(suggestedLimit) {
                    Label(
                        "This is above the 400 mg the FDA suggests as a daily maximum for healthy adults.",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.forum(14))
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .listRowBackground(Color.clear)
        } footer: {
            Text("A starting point, not medical advice. Talk to a doctor if you take medication or have a heart condition.")
                .font(.footnote)
        }
    }

    private var buttonsSection: some View {
        Section {
            Button("Use this limit") {
                dailyLimit = suggestedLimit
                onFinished()
            }
            .font(.forum(19))
            .frame(maxWidth: .infinity)
            .disabled(!hasEnoughAnswers)

            // Letting the user straight into the app, keeping the standard limit
            Button("Skip for now") {
                onFinished()
            }
            .font(.forum(17))
            .foregroundStyle(Color.trackeenLightBrown)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    OnboardingView(onFinished: {})
}
