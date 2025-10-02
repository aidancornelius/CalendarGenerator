import Foundation

class CalendarGenerator {
    private var options: CalendarOptions

    init(options: CalendarOptions) {
        self.options = options
    }

    func generateWeek(startDate: Date) -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let calendar = Calendar.current

        for dayOffset in 0..<7 {
            guard let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            let weekday = calendar.component(.weekday, from: currentDay)
            let isWeekend = weekday == 1 || weekday == 7 // Sunday or Saturday

            if isWeekend {
                events.append(contentsOf: generateWeekendDay(date: currentDay))
            } else {
                events.append(contentsOf: generateWeekday(date: currentDay))
            }
        }

        return events.sorted { $0.startDate < $1.startDate }
    }

    private func generateWeekday(date: Date) -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let calendar = Calendar.current

        // Morning routine and commute
        let wakeTime = randomTime(baseHour: 6, minuteRange: 0...30)
        guard let dayStart = calendar.date(bySettingHour: wakeTime.hour, minute: wakeTime.minute, second: 0, of: date) else { return events }

        // Gym (morning if included)
        var currentTime = dayStart
        if options.includeGym && shouldScheduleGym() {
            let gymDuration = Double.random(in: 45...75) // minutes
            if let gymEnd = calendar.date(byAdding: .minute, value: Int(gymDuration), to: currentTime) {
                events.append(CalendarEvent(
                    title: "Gym",
                    startDate: currentTime,
                    endDate: gymEnd,
                    type: .gym,
                    notes: "Morning workout"
                ))
                currentTime = gymEnd
            }
        }

        // Commute to work
        let commuteDuration = options.profession.category == .professional ?
            Int.random(in: 20...45) : Int.random(in: 15...30)
        if let commuteEnd = calendar.date(byAdding: .minute, value: commuteDuration, to: currentTime) {
            events.append(CalendarEvent(
                title: "Commute to Work",
                startDate: currentTime,
                endDate: commuteEnd,
                type: .commute,
                notes: nil
            ))
            currentTime = commuteEnd
        }

        // Work day
        let workStart = options.profession.typicalStartHour
        let workEnd = options.profession.typicalEndHour

        guard let workStartTime = calendar.date(bySettingHour: workStart, minute: 0, second: 0, of: date) else { return events }
        guard let workEndTime = calendar.date(bySettingHour: workEnd, minute: 0, second: 0, of: date) else { return events }

        currentTime = workStartTime

        // Generate work events throughout the day
        events.append(contentsOf: generateWorkEvents(startTime: workStartTime, endTime: workEndTime))

        // Commute home
        currentTime = workEndTime
        if let commuteHomeEnd = calendar.date(byAdding: .minute, value: commuteDuration, to: currentTime) {
            events.append(CalendarEvent(
                title: "Commute Home",
                startDate: currentTime,
                endDate: commuteHomeEnd,
                type: .commute,
                notes: nil
            ))
            currentTime = commuteHomeEnd
        }

        // Family time
        if options.includeFamilyTime {
            let familyDuration = Double.random(in: 90...180) // 1.5-3 hours
            if let familyEnd = calendar.date(byAdding: .minute, value: Int(familyDuration), to: currentTime) {
                events.append(CalendarEvent(
                    title: "Family Time",
                    startDate: currentTime,
                    endDate: familyEnd,
                    type: .familyTime,
                    notes: "Dinner and family activities"
                ))
                currentTime = familyEnd
            }
        }

        // After hours work
        if options.includeAfterHours && shouldScheduleAfterHours() {
            let afterHoursDuration = Double.random(in: 60...120) // 1-2 hours
            if let afterHoursEnd = calendar.date(byAdding: .minute, value: Int(afterHoursDuration), to: currentTime) {
                events.append(CalendarEvent(
                    title: generateAfterHoursTitle(),
                    startDate: currentTime,
                    endDate: afterHoursEnd,
                    type: .afterHours,
                    notes: "Evening work session"
                ))
            }
        }

        return events
    }

    private func generateWeekendDay(date: Date) -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let calendar = Calendar.current

        // Weekend work
        if options.includeWeekendWork && shouldScheduleWeekendWork() {
            let startHour = Int.random(in: 9...11)
            guard let workStart = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date) else { return events }

            let duration = Double.random(in: 3...5) * 60 // 3-5 hours
            if let workEnd = calendar.date(byAdding: .minute, value: Int(duration), to: workStart) {
                events.append(CalendarEvent(
                    title: generateWeekendWorkTitle(),
                    startDate: workStart,
                    endDate: workEnd,
                    type: .work,
                    notes: "Weekend catch-up"
                ))
            }
        }

        // Gym on weekends
        if options.includeGym && Bool.random() {
            let gymHour = Int.random(in: 8...10)
            guard let gymStart = calendar.date(bySettingHour: gymHour, minute: 0, second: 0, of: date) else { return events }

            let gymDuration = Double.random(in: 60...90) // minutes
            if let gymEnd = calendar.date(byAdding: .minute, value: Int(gymDuration), to: gymStart) {
                events.append(CalendarEvent(
                    title: "Gym",
                    startDate: gymStart,
                    endDate: gymEnd,
                    type: .gym,
                    notes: "Weekend workout"
                ))
            }
        }

        // Family time
        if options.includeFamilyTime {
            let familyHour = Int.random(in: 14...16)
            guard let familyStart = calendar.date(bySettingHour: familyHour, minute: 0, second: 0, of: date) else { return events }

            let familyDuration = Double.random(in: 120...240) // 2-4 hours
            if let familyEnd = calendar.date(byAdding: .minute, value: Int(familyDuration), to: familyStart) {
                events.append(CalendarEvent(
                    title: "Family Time",
                    startDate: familyStart,
                    endDate: familyEnd,
                    type: .familyTime,
                    notes: "Weekend family activities"
                ))
            }
        }

        return events
    }

    private func generateWorkEvents(startTime: Date, endTime: Date) -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let calendar = Calendar.current
        var currentTime = startTime

        while currentTime < endTime {
            let remainingMinutes = calendar.dateComponents([.minute], from: currentTime, to: endTime).minute ?? 0

            if remainingMinutes <= 0 { break }

            // Lunch break
            let lunchHour = calendar.component(.hour, from: currentTime)
            if lunchHour >= 12 && lunchHour < 14 && !hasLunchScheduled(events) {
                let lunchDuration = options.profession.category == .professional ?
                    Int.random(in: 45...60) : Int.random(in: 30...45)

                if let lunchEnd = calendar.date(byAdding: .minute, value: lunchDuration, to: currentTime) {
                    events.append(CalendarEvent(
                        title: "Lunch",
                        startDate: currentTime,
                        endDate: lunchEnd,
                        type: .lunch,
                        notes: nil
                    ))
                    currentTime = lunchEnd
                    continue
                }
            }

            // Generate varied work activities
            let eventDuration = generateWorkEventDuration()
            guard let eventEnd = calendar.date(byAdding: .minute, value: eventDuration, to: currentTime) else { break }

            if eventEnd > endTime {
                // Create final event till end of work day
                events.append(createWorkEvent(start: currentTime, end: endTime))
                break
            }

            events.append(createWorkEvent(start: currentTime, end: eventEnd))
            currentTime = eventEnd

            // Small break between some events
            if Bool.random() && Double.random(in: 0...1) < 0.3 {
                let breakDuration = Int.random(in: 10...15)
                if let breakEnd = calendar.date(byAdding: .minute, value: breakDuration, to: currentTime),
                   breakEnd < endTime {
                    events.append(CalendarEvent(
                        title: "Break",
                        startDate: currentTime,
                        endDate: breakEnd,
                        type: .breakTime,
                        notes: nil
                    ))
                    currentTime = breakEnd
                }
            }
        }

        return events
    }

    private func createWorkEvent(start: Date, end: Date) -> CalendarEvent {
        let workEventTypes: [(EventType, String, Double)] = {
            switch options.profession {
            case .lawyer:
                return [
                    (.meeting, "Client Meeting", 0.3),
                    (.clientCall, "Client Call", 0.2),
                    (.paperwork, "Case Documentation", 0.25),
                    (.projectWork, "Legal Research", 0.25)
                ]
            case .academic:
                return [
                    (.meeting, "Lecture", 0.3),
                    (.meeting, "Tutorial", 0.2),
                    (.projectWork, "Research", 0.3),
                    (.paperwork, "Marking/Admin", 0.2)
                ]
            case .doctor:
                return [
                    (.consultation, "Patient Consultation", 0.5),
                    (.meeting, "Rounds", 0.2),
                    (.paperwork, "Patient Notes", 0.2),
                    (.meeting, "Team Meeting", 0.1)
                ]
            case .accountant:
                return [
                    (.clientCall, "Client Call", 0.2),
                    (.projectWork, "Financial Analysis", 0.3),
                    (.paperwork, "Documentation", 0.3),
                    (.meeting, "Team Meeting", 0.2)
                ]
            case .architect:
                return [
                    (.projectWork, "Design Work", 0.4),
                    (.meeting, "Client Meeting", 0.25),
                    (.onSite, "Site Visit", 0.2),
                    (.paperwork, "Documentation", 0.15)
                ]
            case .engineer:
                return [
                    (.projectWork, "Engineering Work", 0.45),
                    (.meeting, "Team Meeting", 0.25),
                    (.onSite, "Site Inspection", 0.15),
                    (.paperwork, "Reports", 0.15)
                ]
            case .carpenter, .bricklayer, .painter:
                return [
                    (.onSite, "On Site Work", 0.7),
                    (.projectWork, "Preparation", 0.15),
                    (.meeting, "Client Discussion", 0.1),
                    (.paperwork, "Quotes/Invoicing", 0.05)
                ]
            case .plumber, .electrician:
                return [
                    (.onSite, "Job Site", 0.6),
                    (.projectWork, "Installation Work", 0.2),
                    (.meeting, "Client Consultation", 0.1),
                    (.paperwork, "Paperwork", 0.1)
                ]
            case .mechanic:
                return [
                    (.projectWork, "Vehicle Repair", 0.6),
                    (.consultation, "Customer Consultation", 0.2),
                    (.paperwork, "Service Documentation", 0.15),
                    (.meeting, "Parts Ordering", 0.05)
                ]
            }
        }()

        let random = Double.random(in: 0...1)
        var cumulative = 0.0

        for (type, titleBase, probability) in workEventTypes {
            cumulative += probability
            if random <= cumulative {
                return CalendarEvent(
                    title: titleBase,
                    startDate: start,
                    endDate: end,
                    type: type,
                    notes: nil
                )
            }
        }

        // Fallback
        return CalendarEvent(
            title: "Work",
            startDate: start,
            endDate: end,
            type: .work,
            notes: nil
        )
    }

    private func generateWorkEventDuration() -> Int {
        let baseDurations = [30, 45, 60, 90, 120]
        let intensity = options.workIntensity.multiplier

        let duration = baseDurations.randomElement() ?? 60
        return Int(Double(duration) * intensity)
    }

    private func generateAfterHoursTitle() -> String {
        let titles = [
            "Email Catch-up",
            "Project Work",
            "Preparation for Tomorrow",
            "Review Documents",
            "Planning Session"
        ]
        return titles.randomElement() ?? "After Hours Work"
    }

    private func generateWeekendWorkTitle() -> String {
        let titles = [
            "Catch-up Work",
            "Project Deadline",
            "Preparation",
            "Review Session",
            "Planning"
        ]
        return titles.randomElement() ?? "Weekend Work"
    }

    private func shouldScheduleGym() -> Bool {
        let daysPerWeek = Double(options.gymFrequency)
        let probability = daysPerWeek / 5.0 // 5 weekdays
        return Double.random(in: 0...1) < probability
    }

    private func shouldScheduleAfterHours() -> Bool {
        let baseProbability = options.profession.afterHoursLikelihood
        let adjustedProbability = baseProbability * options.workIntensity.multiplier
        return Double.random(in: 0...1) < adjustedProbability
    }

    private func shouldScheduleWeekendWork() -> Bool {
        let baseProbability = options.profession.weekendWorkLikelihood
        let adjustedProbability = baseProbability * options.workIntensity.multiplier
        return Double.random(in: 0...1) < adjustedProbability
    }

    private func hasLunchScheduled(_ events: [CalendarEvent]) -> Bool {
        events.contains { $0.type == .lunch }
    }

    private func randomTime(baseHour: Int, minuteRange: ClosedRange<Int>) -> (hour: Int, minute: Int) {
        let hourVariation = Int.random(in: -1...1)
        let hour = max(0, min(23, baseHour + hourVariation))
        let minute = Int.random(in: minuteRange)
        return (hour, minute)
    }
}
