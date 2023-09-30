//
//  NotificationEditorView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/09/2023.
//

import SwiftUI

enum NotificationInterval: String, CaseIterable {
    case daily, weekly, monthly
    
    var unitDescription: String {
        switch self {
        case .daily:
            return "day"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        }
    }
}

struct NotificationEditorView: View {
    var habit: HabitData
    var onCompletion: (_ content: UNMutableNotificationContent, _ triggerDate: DateComponents, _ notificationIdentifier: UUID) -> Void
    
    @State private var timeOfDay = Date()
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from: startComponents)!
            ...
            calendar.date(from: endComponents)!
    }()
    
    @State private var weekdays = [Int]()
    
    @State var selectedInterval = NotificationInterval.daily
    
    @State private var pickerType: MonthlyPickerType = .offset
    
    @State private var selectedDay: Int = 1
    
    @State private var selectedOffsetValue: OffsetValue = .first
    
    @State private var selectedOffsetWeekday: Int = 1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Select Interval", selection: $selectedInterval) {
                    ForEach(NotificationInterval.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedInterval == .weekly {
                    WeekdayPicker(selectedDays: $weekdays, buttonColor: habit.accentColor)
                }
                
                if selectedInterval == .monthly {
                    MonthlyPicker(pickerType: $pickerType, selectedDay: $selectedDay, selectedOffsetValue: $selectedOffsetValue, selectedOffsetWeekday: $selectedOffsetWeekday, accentColor: habit.accentColor)
                }
                
                HStack {
                    Text("What time of day?")
                        .layoutPriority(1)
                    
                    Spacer()
                    
                    DatePicker(
                        "What time of day?",
                        selection: $timeOfDay,
                        in: dateRange,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .offset(x: 10)
                    .tint(habit.accentColor)
                }
                
                Spacer()
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                UserNotificationsManager.createNotificationData(for: habit, on: timeOfDay, interval: selectedInterval, weekdays: weekdays, monthlyPickerType: pickerType, selectedDay: selectedDay, selectedOffsetValue: selectedOffsetValue, selectedOffsetWeekday: selectedOffsetWeekday) { content, triggerDate, notificationIdentifier in
                    if let content = content, let triggerDate = triggerDate, let notificationIdentifier = notificationIdentifier {
                        onCompletion(content, triggerDate, notificationIdentifier)
                    } else {
                        print("Not all content")
                    }
                }
            } label: {
                Label("Add Notification", systemImage: "bell")
                    .bold()
                    .foregroundColor(habit.accentColor.isDarkBackground() ? .white : .black)
                    .padding(8)
                    .padding(.horizontal, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundStyle(habit.accentColor)
                    }
            }
        }
    }
}

// struct NotificationEditorView_Previews: PreviewProvider {
//    let dataManager = DataManager.preview
//
//    static var previews: some View {
//        NotificationEditorView(habit: Habit.makePreview(context: dataManager.container.viewContext), onCompletion: { _, _ in })
//    }
// }
