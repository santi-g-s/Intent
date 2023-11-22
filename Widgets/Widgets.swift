//
//  Widgets.swift
//  Widgets
//
//  Created by Santiago Garcia Santos on 15/11/2023.
//

import CoreData
import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    #if targetEnvironment(simulator)
    var dataManager = DataManager.shared
    #else
    var dataManager = DataManager.shared
    #endif
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), identifier: UUID().uuidString, displayString: "Placeholder", score: 0.0, streak: 0, timePeriod: .daily, accentColor: .accentColor)
    }

    func getSnapshot(for configuration: HabitProgressIntent, in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let habit = configuration.habit

        let entry = HabitEntry(date: Date(), identifier: habit?.identifier ?? UUID().uuidString, displayString: habit?.displayString ?? "Placeholder", score: Double(truncating: habit?.score ?? 0.0), streak: Int(truncating: habit?.streak ?? 0), timePeriod: TimePeriod(rawValue: Int(truncating: habit?.timePeriod ?? 0)) ?? .daily, accentColor: Color(hex: habit?.accentColor ?? "") ?? .accentColor)

        completion(entry)
    }

    func getTimeline(for configuration: HabitProgressIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let id = configuration.habit?.identifier else {
            print("Configuration doesn't have valid id")
            return
        }

        let predicate = NSPredicate(format: "id = %@", (UUID(uuidString: id) ?? UUID()) as CVarArg)
        let result = DataManager.fetchFirst(Habit.self, predicate: predicate, context: dataManager.viewContext)
        switch result {
        case .success(let habit):
            if let habit = habit {
                let habitEntry = HabitEntry(date: Date(), identifier: habit.id?.uuidString ?? "", displayString: habit.title, score: habit.calculateScore(), streak: habit.streakDescriptionsNumDays ?? 0, timePeriod: habit.timePeriod, accentColor: habit.accentColor)

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
}

struct WidgetsEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading) {
                Text(entry.displayString)
                    .lineLimit(1)
                    .font(.subheadline.bold())
                    .minimumScaleFactor(0.6)
                    .foregroundColor(entry.accentColor)
                Group {
                    Text(entry.streak, format: .number) + Text(" \(entry.timePeriod.unitName) streak")
                }
                .foregroundStyle(.secondary)
                .font(.subheadline.bold())

                Spacer()

                HStack {
                    Spacer()
                    Circle()
                        .foregroundStyle(.regularMaterial)
                        .overlay {
                            Circle()
                                .foregroundColor(entry.accentColor)
                                .scaleEffect(entry.score)
                        }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .widgetBackground(Color(uiColor: .systemBackground))
        default:
            VStack(alignment: .leading) {
                Text(entry.displayString)
                    .lineLimit(1)
                    .font(.subheadline.bold())
                    .minimumScaleFactor(0.6)
                    .foregroundColor(entry.accentColor)
                Group {
                    Text(entry.streak, format: .number) + Text(" \(entry.timePeriod.unitName) streak")
                }
                .foregroundStyle(.secondary)
                .font(.subheadline.bold())

                Spacer()

                HStack {
                    Spacer()
                    Circle()
                        .foregroundStyle(.regularMaterial)
                        .overlay {
                            Circle()
                                .foregroundColor(entry.accentColor)
                                .scaleEffect(entry.score)
                        }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .widgetBackground(Color(uiColor: .systemBackground))
        }
    }
}

struct Widgets: Widget {
    let kind: String = "com.sumone.Intent.widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HabitProgressIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.preview
        let habit = Habit.makePreview(context: dataManager.viewContext)
        let entry = HabitEntry(date: Date(), identifier: habit.id?.uuidString ?? "id", displayString: habit.title, score: habit.calculateScore(), streak: habit.streakDescriptionsNumDays ?? 0, timePeriod: habit.timePeriod, accentColor: habit.accentColor)
        WidgetsEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
