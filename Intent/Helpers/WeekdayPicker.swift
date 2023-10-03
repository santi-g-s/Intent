//
//  WeekdayPicker.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/09/2023.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: [Int]
    var buttonColor: Color = .red

    var orderedWeekdays: [String] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let weekdays = formatter.veryShortWeekdaySymbols ?? ["S", "M", "T", "W", "T", "F", "S"]
        let firstWeekday = calendar.firstWeekday
        return Array(weekdays[(firstWeekday - 1)...]) + Array(weekdays[0 ..< (firstWeekday - 1)])
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0 ..< orderedWeekdays.count, id: \.self) { index in
                    WeekdayButton(
                        title: orderedWeekdays[index],
                        isSelected: selectedDays.contains((index + Calendar.current.firstWeekday - 1) % 7 + 1),
                        buttonColor: buttonColor
                    ) {
                        toggleSelection(day: index)
                    }
                    .frame(width: geometry.size.width / CGFloat(orderedWeekdays.count), height: geometry.size.width / CGFloat(orderedWeekdays.count))
                }
            }
        }
        .frame(height: 32, alignment: .center)
    }

    private func toggleSelection(day: Int) {
        let firstWeekday = Calendar.current.firstWeekday
        let adjustedDay = (day + firstWeekday - 1) % 7 + 1
        if let existingIndex = selectedDays.firstIndex(of: adjustedDay) {
            selectedDays.remove(at: existingIndex)
        } else {
            selectedDays.append(adjustedDay)
        }
    }
}

struct WeekdayButton: View {
    let title: String
    let isSelected: Bool
    let buttonColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.bold())
                .foregroundColor(isSelected ? (buttonColor.isDarkBackground() ? .white : .black) : buttonColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Circle()
                        .fill(isSelected ? buttonColor : Color(uiColor: UIColor.secondarySystemBackground))
                )
                .contentShape(Circle())
        }
        .padding(2)
    }
}

private struct WeekDayPickerPreview: View {
    @State private var weekdays = [Int]()

    var body: some View {
        WeekdayPicker(selectedDays: $weekdays, buttonColor: .accentColor)
    }
}

struct WeekdayPicker_Previews: PreviewProvider {
    static var previews: some View {
        WeekDayPickerPreview()
    }
}
