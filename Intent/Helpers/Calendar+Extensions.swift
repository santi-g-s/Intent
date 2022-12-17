//
//  Calendar+Extensions.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 16/11/2022.
//

import Foundation

extension Calendar {
    
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
    
    func numberOfDaysInclusive(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day! + 1 // <1>
    }
    
    func numberOf24DaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day!
    }
    
    func numberOf24DaysInclusive(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day! + 1
    }
    
    func dates(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while Calendar.current.compare(tempDate, to: to, toGranularity: .day) == .orderedAscending {
            tempDate = self.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }
    
    func dates(from: Date, through: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > through { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while Calendar.current.compare(tempDate, to: through, toGranularity: .day) == .orderedAscending {
            tempDate = self.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        
        if Calendar.current.compare(from, to: through, toGranularity: .day) != .orderedSame {
            array.append(through)
        }

        return array
    }
}


