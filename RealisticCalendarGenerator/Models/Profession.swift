import Foundation

enum ProfessionCategory: String, CaseIterable, Identifiable {
    case professional = "Professional"
    case tradesperson = "Tradesperson"

    var id: String { rawValue }
}

enum ProfessionType: String, CaseIterable, Identifiable {
    // Professional
    case lawyer = "Lawyer"
    case academic = "Academic"
    case doctor = "Doctor"
    case accountant = "Accountant"
    case architect = "Architect"
    case engineer = "Engineer"

    // Tradesperson
    case carpenter = "Carpenter"
    case bricklayer = "Bricklayer"
    case plumber = "Plumber"
    case electrician = "Electrician"
    case painter = "Painter"
    case mechanic = "Mechanic"

    var id: String { rawValue }

    var category: ProfessionCategory {
        switch self {
        case .lawyer, .academic, .doctor, .accountant, .architect, .engineer:
            return .professional
        case .carpenter, .bricklayer, .plumber, .electrician, .painter, .mechanic:
            return .tradesperson
        }
    }

    // Typical working hours
    var typicalStartHour: Int {
        switch category {
        case .professional:
            return 9
        case .tradesperson:
            return 7
        }
    }

    var typicalEndHour: Int {
        switch category {
        case .professional:
            return 17
        case .tradesperson:
            return 15
        }
    }

    // Likelihood of after-hours work (0-1)
    var afterHoursLikelihood: Double {
        switch self {
        case .lawyer, .doctor:
            return 0.6
        case .academic, .architect, .engineer:
            return 0.4
        case .accountant:
            return 0.3
        case .carpenter, .bricklayer, .plumber, .electrician, .painter, .mechanic:
            return 0.15
        }
    }

    // Weekend work likelihood (0-1)
    var weekendWorkLikelihood: Double {
        switch self {
        case .doctor:
            return 0.5
        case .lawyer:
            return 0.4
        case .academic, .engineer:
            return 0.2
        case .carpenter, .plumber, .electrician, .mechanic:
            return 0.3
        case .bricklayer, .painter:
            return 0.1
        case .accountant, .architect:
            return 0.15
        }
    }
}

struct CalendarOptions: Equatable {
    var profession: ProfessionType
    var includeGym: Bool
    var gymFrequency: Int // times per week
    var includeFamilyTime: Bool
    var includeWeekendWork: Bool
    var includeAfterHours: Bool
    var workIntensity: WorkIntensity

    enum WorkIntensity: String, CaseIterable, Identifiable {
        case light = "Light"
        case moderate = "Moderate"
        case intense = "Intense"

        var id: String { rawValue }

        var multiplier: Double {
            switch self {
            case .light: return 0.7
            case .moderate: return 1.0
            case .intense: return 1.3
            }
        }
    }

    static func `default`(profession: ProfessionType) -> CalendarOptions {
        CalendarOptions(
            profession: profession,
            includeGym: true,
            gymFrequency: 3,
            includeFamilyTime: true,
            includeWeekendWork: false,
            includeAfterHours: false,
            workIntensity: .moderate
        )
    }
}
