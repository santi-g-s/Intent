//
//  CalendarView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 07/12/2022.
//

import SwiftUI

fileprivate extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

fileprivate extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let week: Date
    let content: (Date) -> DateView

    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self.content = content
    }

    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
            else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                Group {
                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.content(date)
                    } else {
                        self.content(date).hidden()
                    }
                }
                if (date != days.last) {
                    Spacer()
                }
            }
        }
    }
}

struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let month: Date
    let showHeader: Bool
    let formatter: DateFormatter
    let content: (Date) -> DateView

    init(
        month: Date,
        showHeader: Bool = true,
        formatter: DateFormatter,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
        self.formatter = formatter
        self.showHeader = showHeader
    }

    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
            else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday)
        )
    }

    private var header: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return Text(month.formatted(.dateTime.month(.abbreviated).year(.twoDigits)).uppercased())
            .font(Font.system(.title, design: .rounded, weight: .bold))
            .foregroundStyle(.tertiary)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            if showHeader {
                header
                HStack {
                    let firstWeekday = calendar.firstWeekday
                    let weekdays = formatter.veryShortWeekdaySymbols ?? ["S", "M", "T", "W", "T", "F", "S"]
                    let orderedWeekdays = Array(weekdays[(firstWeekday - 1)...]) + Array(weekdays[0..<(firstWeekday - 1)])

                    ForEach(orderedWeekdays.indices, id: \.self) { index in
                        Text(orderedWeekdays[index].description)
                            .font(.subheadline.bold())
                            .foregroundStyle(.tertiary)
                        if index != orderedWeekdays.count-1 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            ForEach(weeks.reversed(), id: \.self) { week in
                WeekView(week: week, content: self.content)
            }
        }
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let interval: DateInterval
    let content: (Date) -> DateView
    
    let formatter = DateFormatter()

    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }

    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        LazyVStack {
            ForEach(months.reversed(), id: \.self) { month in
                MonthView(month: month, formatter: formatter, content: self.content)
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            CalendarView(interval: DateInterval(start: Date().addingTimeInterval(-60*60*24*365*5), end: Date())) { date in
                Text("30")
                    .hidden()
                    .padding(8)
                    .background(Color.accentColor.opacity(2/3))
                    .clipShape(Circle())
                    .padding(.vertical, 4)
                    .overlay(
                        Text(String(Calendar.current.component(.day, from: date)))
                            .foregroundColor(.white)
                    )
            }
            .padding()
        }
    }
}
