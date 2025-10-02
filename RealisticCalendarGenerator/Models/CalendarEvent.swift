import Foundation
import EventKit

enum EventType: String {
    case work = "Work"
    case meeting = "Meeting"
    case clientCall = "Client Call"
    case projectWork = "Project Work"
    case paperwork = "Paperwork"
    case onSite = "On Site"
    case consultation = "Consultation"
    case gym = "Gym"
    case familyTime = "Family Time"
    case breakTime = "Break"
    case lunch = "Lunch"
    case commute = "Commute"
    case afterHours = "After Hours Work"

    var color: String {
        switch self {
        case .work, .meeting, .clientCall, .projectWork, .onSite, .consultation:
            return "blue"
        case .paperwork:
            return "purple"
        case .gym:
            return "green"
        case .familyTime:
            return "orange"
        case .breakTime, .lunch:
            return "gray"
        case .commute:
            return "yellow"
        case .afterHours:
            return "red"
        }
    }
}

struct CalendarEvent: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var type: EventType
    var notes: String?

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var durationInHours: Double {
        duration / 3600
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

extension CalendarEvent {
    func toEKEvent(in eventStore: EKEventStore) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        return event
    }
}
