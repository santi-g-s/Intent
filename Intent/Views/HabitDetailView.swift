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
    
    @State var index = 0
    
    var body: some View {
        LazyVStack(spacing: 0){
            
            TabView {
                ForEach(habit.messages, id: \.self) { message in
                    Text(message)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .font(Font.system(.title3, design: .serif, weight: .regular))
                        .foregroundStyle(.primary)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color(uiColor: UIColor.secondarySystemGroupedBackground)).shadow(color: Color.black.opacity(0.1), radius: 5))
                        .padding()
                }
                .padding(.bottom)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .frame(height: 200)
            .id(0)
            .onAppear() {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
                UIPageControl.appearance().pageIndicatorTintColor = .tertiaryLabel
            }
            
            CalendarView(interval: DateInterval(start: habit.startDate.addingTimeInterval(-3*31*24*60*60), end: Date())) { date in
                
                let isComplete = completionMap[Calendar.current.standardizedDate(date)] == true
                
                Text("30")
                    .hidden()
                    .padding(8)
                    .background(isComplete ? habit.accentColor : .clear)
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
}

struct HabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.preview
        
        let habit = Habit.makePreview(context: dataManager.viewContext)
        
        ScrollView {
            HabitDetailView(habit: habit, completionMap: habit.calculateCompletionMap())
        }
    }
}
