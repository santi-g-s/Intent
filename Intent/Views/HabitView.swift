//
//  HabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI

struct HabitView: View {
    
    @ObservedObject var habit: Habit
    @State var habitScore = 0.0
    @State var completionMap = [Date : Bool]()
    
    @State var showDetail = false
    @State var scrollOffset: CGPoint = .zero
    
    @State var returnToTop = false
    
    var body: some View {
        VStack(spacing: 0){
            Text(habit.title)
                .font(Font.system(.largeTitle, design: .serif))
                .onTapGesture {
                    returnToTop.toggle()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .scaleEffect(max(2/3, min((250+scrollOffset.y) / 250, 1.2)), anchor: .top)
                .overlay(alignment: .top) {
                    HStack {
                        Spacer()
                        Button {
                            //
                        } label: {
                            Image(systemName: "slider.vertical.3")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                    .disabled(!showDetail)
                    .opacity(max(0.0, min((-scrollOffset.y) / 250, 1.0)))
                    .padding(.top, 4)
                    .padding(.horizontal)
                }
            
            GeometryReader { geoReader in
                ScrollViewReader { proxy in
                    ScrollViewOffset(
                        axes: [.vertical],
                        showsIndicators: false,
                        offsetChanged: { offset in
                            self.scrollOffset = offset
                            if showDetail == false {
                                if (offset.y < -150) {
                                    showDetail = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                        withAnimation {
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                        let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                        
                                    }
                                }
                            } else {
                                if (offset.y > -20) {
                                    showDetail = false
                                }
                            }
                        }
                    ) {
                        LazyVStack {
                            content
                                .frame(height: geoReader.size.height)
                                .id("top")
                            if showDetail {
                                HabitDetailView(habit: habit, completionMap: completionMap)
                            }
                        }
                    }
                    .onChange(of: returnToTop) { _ in
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.none){
                (habitScore, completionMap) = habit.calculateScore()
            }
        }
        .onChange(of: habit.completedDates) { _ in
            (habitScore, completionMap) = habit.calculateScore()
        }
    }
    
    var content: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.gray.opacity(0.15))
               
                Circle()
                    .foregroundColor(habit.accentColor.opacity(habit.status == .complete ? 1 : 0.5))
                    .scaleEffect(habitScore)
                    .overlay {
                        Group {
                            switch habit.status {
                            case .complete:
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                                    .foregroundStyle(.tertiary)
                            case .pending(let score):
                                if score != 0 {
                                    Text("\(score) / \(habit.requiredCount)")
                                        .font(.title3)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: habitScore)
            }
            .onTapGesture { habit.complete() }
            .frame(minHeight: 0, maxHeight: .infinity)
            
        }
        .overlay(alignment: .top) {
            VStack {
                if let dateStartedDescription = habit.dateStartedDescription {
                    Text(dateStartedDescription)
                        .font(Font.system(.subheadline, design: .serif))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(showDetail ? "See less" : "See more")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.gray.opacity(1/3))
                Image(systemName: showDetail ? "chevron.compact.down" : "chevron.compact.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.gray.opacity(1/3))
            }
            
        }
        .padding(.horizontal, 40)
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.preview
        
        HabitView(habit: Habit.makePreview(context: dataManager.container.viewContext))
    }
}
