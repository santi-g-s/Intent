//
//  HabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI

struct HabitView: View {
    
    @ObservedObject var habit: Habit
    
    @State var size = CGSize.zero
    
    @State var showDetail = false
    
    var body: some View {
        VStack {
            if showDetail {
                Text(habit.title)
                    .font(Font.system(.title, design: .serif))
                    .transition(.opacity)
                    .animation(.easeInOut, value: showDetail)
            } else {
                HStack(spacing: 16){
                    Image(systemName: "figure.run")
                        .foregroundColor(.gray.opacity(1/3))
                    Image(systemName: "fork.knife")
                        .foregroundColor(.primary)
                    Image(systemName: "book")
                        .foregroundColor(.gray.opacity(1/3))
                    Image(systemName: "plus")
                        .foregroundColor(.gray.opacity(1/3))
                }
                .padding()
            }
            
            ScrollViewReader { proxy in
                ScrollView(
                    axes: [.vertical],
                    showsIndicators: false,
                    offsetChanged: { offset in
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
                            .frame(height: size.height)
                        if showDetail {
                            ForEach(0..<100) { i in
                                Text("Example \(i)")
                                    .padding()
                                    .id(i)
                            }
                        }
                    }
                }
            }
            .readSize { size in
                self.size = size
            }
        }
    }
    
    var content: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.gray.opacity(0.15))
               
                Circle()
                    .foregroundColor(.accentColor.opacity(habit.status == .complete ? 1 : 0.5))
                    .scaleEffect(habit.score)
                    .overlay {
                        Group {
                            switch habit.status {
                            case .complete:
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                                    .foregroundStyle(.thinMaterial)
                            case .pending(let score):
                                if score != 0 {
                                    Text("\(score) / \(habit.requiredCount)")
                                        .font(.title3)
                                        .foregroundStyle(.regularMaterial)
                                }
                            }
                        }
                        
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: habit.score)
            }
            .onTapGesture { habit.complete() }
            .frame(minHeight: 0, maxHeight: .infinity)
            
        }
        .overlay(alignment: .top) {
            VStack {
                Text(habit.title)
                    .font(Font.system(.largeTitle, design: .serif))
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
