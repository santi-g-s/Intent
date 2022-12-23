//
//  HabitDetailView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI

struct HabitDetailView: View {
    
    var habit: Habit
    var completionMap: [Date : Bool]
    
    var body: some View {
        CalendarView(interval: DateInterval(start: habit.startDate, end: Date())) { date in
            
            let isComplete = completionMap[Calendar.current.standardizedDate(date)] == true
            
            Text("30")
                .hidden()
                .padding(8)
                .background(isComplete ? Color.accentColor : .clear)
                .clipShape(Circle())
                .padding(.vertical, 4)
                .overlay(
                    Text(String(Calendar.current.component(.day, from: date)))
                        .foregroundColor(isComplete ? .white : .secondary)
                        .fontWeight(isComplete ? .bold : .regular)
                )
        }
        .padding()
    }
}
