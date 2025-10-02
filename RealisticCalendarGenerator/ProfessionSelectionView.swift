import SwiftUI

struct ProfessionSelectionView: View {
    @State private var selectedCategory: ProfessionCategory = .professional
    @State private var selectedProfession: ProfessionType = .lawyer
    @State private var options: CalendarOptions
    @State private var showCalendar = false

    init() {
        let initialOptions = CalendarOptions.default(profession: .lawyer)
        _options = State(initialValue: initialOptions)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profession") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ProfessionCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Profession", selection: $selectedProfession) {
                        ForEach(professionsForCategory) { profession in
                            Text(profession.rawValue).tag(profession)
                        }
                    }
                    .onChange(of: selectedProfession) { newValue in
                        options.profession = newValue
                    }
                }

                Section("Work intensity") {
                    Picker("Intensity", selection: $options.workIntensity) {
                        ForEach(CalendarOptions.WorkIntensity.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("Include after-hours work", isOn: $options.includeAfterHours)
                    Toggle("Include weekend work", isOn: $options.includeWeekendWork)
                }

                Section("Lifestyle") {
                    Toggle("Include gym sessions", isOn: $options.includeGym)

                    if options.includeGym {
                        Stepper("Gym frequency: \(options.gymFrequency) times/week",
                               value: $options.gymFrequency,
                               in: 1...7)
                    }

                    Toggle("Include family time", isOn: $options.includeFamilyTime)
                }

                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Typical hours",
                               value: "\(options.profession.typicalStartHour):00 - \(options.profession.typicalEndHour):00")
                        InfoRow(label: "After-hours likelihood",
                               value: "\(Int(options.profession.afterHoursLikelihood * 100))%")
                        InfoRow(label: "Weekend work likelihood",
                               value: "\(Int(options.profession.weekendWorkLikelihood * 100))%")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Calendar generator")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Generate") {
                        showCalendar = true
                    }
                }
            }
            .navigationDestination(isPresented: $showCalendar) {
                CalendarDisplayView(options: options)
            }
        }
    }

    private var professionsForCategory: [ProfessionType] {
        ProfessionType.allCases.filter { $0.category == selectedCategory }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfessionSelectionView()
}
