import SwiftUI
import EventKit

struct CalendarDisplayView: View {
    let options: CalendarOptions
    @State private var events: [CalendarEvent] = []
    @State private var selectedDate: Date = Date()
    @State private var showExportSheet = false
    @State private var exportMessage = ""
    @State private var showExportAlert = false

    private let generator: CalendarGenerator

    init(options: CalendarOptions) {
        self.options = options
        self.generator = CalendarGenerator(options: options)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Week selector
            WeekSelector(selectedDate: $selectedDate, onDateChange: generateCalendar)
                .padding()
                .background(Color(.systemGroupedBackground))

            // Events list
            if events.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("No events")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Generate a calendar to see events")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedEventsByDay.keys.sorted(), id: \.self) { date in
                            DaySection(date: date, events: groupedEventsByDay[date] ?? [])
                        }
                    }
                }
            }
        }
        .navigationTitle(options.profession.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Regenerate week", systemImage: "arrow.clockwise") {
                        generateCalendar()
                    }

                    Button("Export to calendar", systemImage: "square.and.arrow.up") {
                        exportToCalendar()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            generateCalendar()
        }
        .alert("Export status", isPresented: $showExportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportMessage)
        }
    }

    private var groupedEventsByDay: [Date: [CalendarEvent]] {
        let calendar = Calendar.current
        return Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.startDate)
        }
    }

    private func generateCalendar() {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) else { return }

        events = generator.generateWeek(startDate: weekStart)
    }

    private func exportToCalendar() {
        let eventStore = EKEventStore()

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    self.handleCalendarExport(eventStore: eventStore, granted: granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    self.handleCalendarExport(eventStore: eventStore, granted: granted)
                }
            }
        }
    }

    private func handleCalendarExport(eventStore: EKEventStore, granted: Bool) {
        if granted {
            var successCount = 0
            var failureCount = 0

            for event in events {
                let ekEvent = event.toEKEvent(in: eventStore)

                do {
                    try eventStore.save(ekEvent, span: .thisEvent)
                    successCount += 1
                } catch {
                    failureCount += 1
                }
            }

            exportMessage = "Exported \(successCount) events to your calendar"
            if failureCount > 0 {
                exportMessage += "\n\(failureCount) events failed"
            }
        } else {
            exportMessage = "Calendar access was denied. Please grant permission in Settings."
        }
        showExportAlert = true
    }
}

struct WeekSelector: View {
    @Binding var selectedDate: Date
    let onDateChange: () -> Void

    private var weekRange: String {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        let startString = formatter.string(from: weekStart)
        let endString = formatter.string(from: weekEnd)

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: weekEnd)

        return "\(startString) - \(endString), \(year)"
    }

    var body: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            Text(weekRange)
                .font(.headline)

            Spacer()

            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
        .buttonStyle(.bordered)
    }

    private func previousWeek() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
            selectedDate = newDate
            onDateChange()
        }
    }

    private func nextWeek() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
            selectedDate = newDate
            onDateChange()
        }
    }
}

struct DaySection: View {
    let date: Date
    let events: [CalendarEvent]

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date)
    }

    private var totalHours: Double {
        events.reduce(0) { $0 + $1.durationInHours }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(dayString)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1fh", totalHours))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ForEach(events.sorted(by: { $0.startDate < $1.startDate })) { event in
                EventRow(event: event)
                Divider()
                    .padding(.leading)
            }
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let start = formatter.string(from: event.startDate)
        let end = formatter.string(from: event.endDate)
        return "\(start) - \(end)"
    }

    private var durationString: String {
        let hours = Int(event.durationInHours)
        let minutes = Int((event.durationInHours - Double(hours)) * 60)

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(colorForType(event.type))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Label(timeString, systemImage: "clock")
                    Text("•")
                    Text(durationString)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let notes = event.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 12)

            Spacer()
        }
        .background(Color(.systemBackground))
    }

    private func colorForType(_ type: EventType) -> Color {
        switch type.color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "gray": return .gray
        case "yellow": return .yellow
        case "red": return .red
        default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        CalendarDisplayView(options: CalendarOptions.default(profession: .lawyer))
    }
}
