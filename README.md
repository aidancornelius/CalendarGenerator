# Realistic calendar generator

An iOS developer utility app that generates realistic working calendars for different professional categories and lifestyles.

## Features

### Profession categories

**Professionals:**
- Lawyer
- Academic
- Doctor
- Accountant
- Architect
- Engineer

**Tradespeople:**
- Carpenter
- Bricklayer
- Plumber
- Electrician
- Painter
- Mechanic

### Customisation options

- **Work intensity**: Light, moderate, or intense
- **After-hours work**: Toggle to include evening work sessions
- **Weekend work**: Toggle to include weekend catch-up work
- **Gym sessions**: Include gym visits with customisable frequency (1-7 times per week)
- **Family time**: Include dedicated family time slots

### Calendar generation

The app generates realistic weekly schedules that include:
- Typical work hours for each profession
- Meetings, client calls, and project work
- On-site visits (for relevant professions)
- Commute times
- Lunch breaks and break times
- Gym sessions
- Family time
- After-hours work (profession-dependent)
- Weekend activities

### Export functionality

Generated calendars can be exported directly to your iOS Calendar app with full event details.

## Technical details

- **Platform**: iOS 16.0+
- **Framework**: SwiftUI
- **Architecture**: MVVM pattern
- **Dependencies**: EventKit for calendar integration

## Project structure

```
RealisticCalendarGenerator/
├── Models/
│   ├── Profession.swift          # Profession types and configurations
│   └── CalendarEvent.swift       # Event data model
├── Services/
│   └── CalendarGenerator.swift   # Calendar generation logic
├── Views/
│   ├── ContentView.swift
│   ├── ProfessionSelectionView.swift  # Main configuration screen
│   └── CalendarDisplayView.swift      # Calendar display and export
└── RealisticCalendarGeneratorApp.swift
```

## Building and running

1. Open `RealisticCalendarGenerator.xcodeproj` in Xcode
2. Select a simulator or device target
3. Build and run (⌘R)

## Usage

1. Select a profession category (professional or tradesperson)
2. Choose a specific profession
3. Configure work intensity and lifestyle options
4. Tap "Generate" to create a realistic weekly calendar
5. Review the generated events
6. Use the menu to regenerate or export to Calendar

## Permissions

The app requires calendar access to export generated events. You'll be prompted to grant permission when attempting to export.
