//
//  NotificationEditorView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/09/2023.
//

import SwiftUI

struct NotificationEditorView: View {
    
    @State private var date = Date()
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
        ...
        calendar.date(from:endComponents)!
    }()
    
    @State private var weekdays = [Int]()
    
    var body: some View {
        VStack {
            WeekdayPicker(selectedDays: $weekdays, buttonColor: .accentColor)
                .padding(.vertical)
                
            
            DatePicker(
                "Start Date",
                 selection: $date,
                 in: dateRange,
                 displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.graphical)
            
            Spacer()
        }
        .padding()
    }
}

struct NotificationEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationEditorView()
    }
}
