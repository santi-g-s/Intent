//
//  WeekdayPicker.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/09/2023.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: [Int]
    let weekdays = Calendar.current.veryShortWeekdaySymbols
    var buttonColor: Color = .red

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<weekdays.count, id: \.self) { index in
                    WeekdayButton(
                        title: weekdays[index],
                        isSelected: selectedDays.contains(index + 1),
                        buttonColor: buttonColor
                    ) {
                        toggleSelection(day: index + 1)
                    }
                    .frame(width: geometry.size.width / CGFloat(weekdays.count), height: geometry.size.width / CGFloat(weekdays.count))
                }
            }
        }
        .frame(height: 32, alignment: .center)
    }

    private func toggleSelection(day: Int) {
        if let existingIndex = selectedDays.firstIndex(of: day) {
            selectedDays.remove(at: existingIndex)
        } else {
            selectedDays.append(day)
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
                .foregroundColor(isSelected ? .white : .accentColor)
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

