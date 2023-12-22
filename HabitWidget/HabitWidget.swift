//
//  HabitWidget.swift
//  HabitWidget
//
//  Created by Santiago Garcia Santos on 21/12/2023.
//

import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    var dataManager = DataManager.shared
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry()
    }

    func getSnapshot(for configuration: HabitProgressIntent, in context: Context, completion: @escaping (HabitEntry) -> ()) {
        guard let id = configuration.habit?.identifier else {
            print("No identifier")
            print(configuration)
            return
        }

        let predicate = NSPredicate(format: "id = %@", (UUID(uuidString: id) ?? UUID()) as CVarArg)
        let result = DataManager.fetchFirst(Habit.self, predicate: predicate, context: dataManager.viewContext)
        switch result {
        case .success(let habit):
            if let habit = habit {
                let habitEntry = HabitEntry(from: habit)

                completion(habitEntry)
            } else {
                print("Couldn't find habit with id: \(id)")
            }
        case .failure:
            print("Couldn't fetch Habit")
        }
    }

    func getTimeline(for configuration: HabitProgressIntent, in context: Context, completion: @escaping (Timeline<HabitEntry>) -> ()) {
        guard let id = configuration.habit?.identifier else {
            print("No identifier")
            print(configuration)
            return
        }

        let predicate = NSPredicate(format: "id = %@", (UUID(uuidString: id) ?? UUID()) as CVarArg)
        let result = DataManager.fetchFirst(Habit.self, predicate: predicate, context: dataManager.viewContext)
        switch result {
        case .success(let habit):
            if let habit = habit {
                let habitEntry = HabitEntry(from: habit)

                let timeline = Timeline(entries: [habitEntry], policy: .atEnd)

                completion(timeline)
            } else {
                print("Couldn't find habit with id: \(id)")
            }
        case .failure:
            print("Couldn't fetch Habit")
        }
    }
}

struct HabitEntry: TimelineEntry {
    var date: Date
    var identifier: String
    var displayString: String
    var score: Double
    var streak: Int
    var timePeriod: TimePeriod
    var accentColor: Color
    var iconName: String
    var messages: [String]
    var completionsInPeriod: Int
    var requiredCount: Int
    var status: HabitStatus

    init() {
        self.date = Date()
        self.identifier = UUID().uuidString
        self.displayString = "Habit"
        self.score = 0.6
        self.streak = 15
        self.timePeriod = .daily
        self.accentColor = .accentColor
        self.iconName = "sparkles"
        self.messages = ["Add a motivational message to help you reach your goals"]
        self.completionsInPeriod = 1
        self.requiredCount = 1
        self.status = .complete
    }

    init(from habit: Habit) {
        self.date = Date()
        self.identifier = habit.id?.uuidString ?? ""
        self.displayString = habit.title
        self.score = habit.calculateScore()
        self.streak = habit.streakDescriptionsNumDays ?? 0
        self.timePeriod = habit.timePeriod
        self.accentColor = habit.accentColor
        self.iconName = habit.iconName
        self.messages = habit.messages
        self.completionsInPeriod = habit.completionsInPeriod
        self.requiredCount = habit.requiredCount
        self.status = habit.status
    }
}

struct HabitWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var partialCircleProgress: Double {
        let progress = Double(entry.completionsInPeriod)/Double(entry.requiredCount)
        return progress.isEqual(to: 0.0) ? 1.0 : progress
    }

    var habitIndicator: some View {
        PartialCircle(progress: partialCircleProgress)
            .foregroundColor(entry.accentColor.opacity(entry.status != .pending(0) ? 1 : 2/3))
            .shadow(color: entry.accentColor.adjust(brightness: -0.3).opacity(0.2), radius: entry.status == .complete ? 4 : 0, x: 0, y: 0)
            .scaleEffect(entry.score.roundedUp(toNearest: 0.1))
    }

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(entry.displayString)
                        .lineLimit(1)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .minimumScaleFactor(0.6)
                        .foregroundColor(entry.accentColor)
                    Spacer()
                    Image(systemName: entry.iconName)
                        .imageScale(.small)
                        .foregroundColor(entry.accentColor)
                }

                HStack(spacing: 0) {
                    Text(entry.streak, format: .number)
                        .font(.system(.subheadline, design: .rounded)).bold()
                        .foregroundColor(entry.accentColor)
                        .padding(2)
                        .padding(.horizontal, 2)
                        .background {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .foregroundStyle(.regularMaterial)
                        }

                    Text(" \(entry.timePeriod.unitName) streak")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)

                Spacer()

                HStack {
                    Spacer()

                    Circle()
                        .foregroundStyle(.regularMaterial)
                        .overlay {
                            habitIndicator
                        }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .widgetBackground(Color(uiColor: .systemBackground))
        default:
            HStack(spacing: 16) {
                Circle()
                    .foregroundStyle(.regularMaterial)
                    .overlay {
                        habitIndicator
                    }
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text(entry.displayString)
                            .lineLimit(1)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .minimumScaleFactor(0.6)
                            .foregroundColor(entry.accentColor)
                        Spacer()
                        Image(systemName: entry.iconName)
                            .imageScale(.small)
                            .foregroundColor(entry.accentColor)
                    }
                    HStack(spacing: 0) {
                        Text(entry.streak, format: .number)
                            .font(.system(.subheadline, design: .rounded)).bold()
                            .foregroundColor(entry.accentColor)
                            .padding(2)
                            .padding(.horizontal, 2)
                            .background {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .foregroundStyle(.regularMaterial)
                            }

                        Text(" \(entry.timePeriod.unitName) streak")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)

                    Spacer()

                    if let message = entry.messages.randomElement() {
                        Text(message)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .widgetBackground(Color(uiColor: .systemBackground))
        }
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct HabitWidget: Widget {
    let kind: String = "com.sumone.Intent.HabitWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HabitProgressIntent.self, provider: Provider(), content: { entry in
            HabitWidgetEntryView(entry: entry)
        })
        .configurationDisplayName("Habit Tracker")
        .description("Quickly glance at a habit's information.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HabitWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = HabitEntry()
        Group {
            HabitWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            HabitWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
