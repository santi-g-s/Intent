//
//  Date+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 27/12/2022.
//

import Foundation

extension Date {
    func startOfWeek(using calendar: Calendar = Calendar.current) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}
