//
//  HabitDetailView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI

struct HabitDetailView: View {
    @ObservedObject var habit: Habit
    var completionMap: [Date: Int]
    
    @State var index = 0
    
    var body: some View {
        LazyVStack(spacing: 0) {
            detailView
                .id(0)
            
            messageView
                
            calendarView
        }
    }
    
    var detailView: some View {
        VStack {
            HStack(spacing: 5) {
                Image(systemName: "calendar")
                Text(habit.scheduleDescription)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity)
            .overlay(alignment: .trailing, content: {
                if !habit.notificationIdentifiers.isEmpty {
                    Image(systemName: "bell.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            })
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundStyle(.regularMaterial)
            }
            
            .padding(.horizontal)
        }
    }
    
    @State var confirmationDialogueDate: Date? = nil
    @State var showConfirmationDialogue = false
    
    var calendarView: some View {
        CalendarView(interval: DateInterval(start: min(Date().adding(.month, value: -2), habit.startDate), end: Date())) { date in
            
            let isComplete = completionMap[Calendar.current.standardizedDate(date)] ?? 0 >= 1
            
            let isToday = Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedSame
            Group {
                if !isComplete {
                    Text("30")
                        .hidden()
                        .padding(8)
                        .background(.clear)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isToday ? habit.accentColor : Color.clear, lineWidth: 2)
                                .scaleEffect(1.1)
                        )
                        .padding(.vertical, 4)
                        .overlay(
                            Text(String(Calendar.current.component(.day, from: date)))
                                .foregroundColor(.secondary)
                                .fontWeight(.regular)
                        )
                } else {
                    Text("30")
                        .hidden()
                        .padding(8)
                        .background(habit.accentColor)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isToday ? habit.accentColor : Color.clear, lineWidth: 2)
                                .scaleEffect(1.2)
                        )
                        .padding(.vertical, 4)
                        .overlay(
                            Text(String(Calendar.current.component(.day, from: date)))
                                .foregroundColor(habit.accentColor.isDarkBackground() ? .white : .black)
                                .fontWeight(.bold)
                        )
                        .overlay(alignment: .topTrailing, content: {
                            if completionMap[Calendar.current.standardizedDate(date)] ?? 0 > 1, let multiplier = completionMap[Calendar.current.standardizedDate(date)] {
                                Text("x\(multiplier)")
                                    .foregroundColor(.secondary)
                                    .font(.system(.caption, design: .rounded, weight: .bold))
                                    .padding(2)
                                    .background(Circle().foregroundStyle(.regularMaterial))
                                    .offset(x: 4, y: -4)
                            }
                            
                        })
                }
            }
            .onTapGesture {
                if Calendar.current.compare(date, to: Date(), toGranularity: .day) != .orderedDescending {
                    showConfirmationDialogue = true
                    confirmationDialogueDate = date
                }
            }
        }
        .confirmationDialog((confirmationDialogueDate ?? Date()).formatted(date: .complete, time: .omitted), isPresented: $showConfirmationDialogue, titleVisibility: .visible, presenting: confirmationDialogueDate ?? Date()) { date in
            Button {
                habit.addCompletion(on: date)
            } label: {
                Text("Add Completion")
            }
            // If let completedDates matches a date item
            if habit.hasCompletion(on: date) {
                Button(role: .destructive) {
                    habit.removeCompletion(on: date)
                } label: {
                    Text("Remove Completion")
                }
            }
        }
        .padding()
    }
    
    @State var tabViewSelectionIndex = 0
    
    var messageView: some View {
        Group {
            if !habit.messages.isEmpty {
                TabView(selection: $tabViewSelectionIndex) {
                    ForEach(habit.messages.indices, id: \.self) { index in
                        Text(habit.messages[index])
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(uiColor: UIColor.secondarySystemGroupedBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8)
                            }
                            .padding()
                    }
                    .padding(.bottom)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .frame(height: 200)
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
                    UIPageControl.appearance().pageIndicatorTintColor = .tertiaryLabel
                }
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text("Tap ") + Text(Image(systemName: "slider.vertical.3")) + Text(" to add a motivational message")
                }
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(.regularMaterial))
                .padding()
            }
        }
        .onAppear {
            if habit.messages.count != 0 {
                tabViewSelectionIndex = Int.random(in: 0 ..< habit.messages.count)
            }
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
