//
//  MonthlyPicker.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/09/2023.
//

import SwiftUI

struct MonthlyPicker: View {
    @Binding var pickerType: MonthlyPickerType
    @Binding var selectedDay: Int
    @Binding var selectedOffsetValue: OffsetValue
    @Binding var selectedOffsetWeekday: Int
    var accentColor: Color

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)

    let weekdays = Calendar.current.weekdaySymbols

    var body: some View {
        VStack {
            Picker("Select Type", selection: $pickerType) {
                ForEach(MonthlyPickerType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if pickerType == .dayOfMonth {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(1 ... 31, id: \.self) { day in
                        Text("\(day)")
                            .bold(selectedDay == day)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44)
                            .background(selectedDay == day ? accentColor : Color(uiColor: UIColor.systemBackground))
                            .foregroundColor(selectedDay == day ? (accentColor.isDarkBackground() ? .white : .primary) : .primary)
                            .cornerRadius(32)
                            .onTapGesture {
                                selectedDay = day
                            }
                    }
                }
                .padding(.vertical)
            }

            if pickerType == .offset {
                HStack(spacing: 0) {
                    Picker("Select Type", selection: $selectedOffsetValue) {
                        ForEach(OffsetValue.allCases, id: \.self) { type in
                            Text(type.stringValue).tag(type)
                        }
                    }
                    .pickerStyle(.wheel)
                    Picker("Select Type", selection: $selectedOffsetWeekday) {
                        ForEach(0 ..< weekdays.count, id: \.self) { index in
                            Text(weekdays[index])
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
    }
}
