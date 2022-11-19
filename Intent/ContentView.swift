//
//  ContentView.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 11/11/2022.
//

import SwiftUI

//TODO: Color will be lighter when yet to complete. Then opaque when completed. In case of multiple tiems per day. Light gets gradually more opaque.

struct ContentView: View {
    
    @ObservedObject var habit: Habit
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.gray.opacity(0.15))
               
                Circle()
                    .foregroundColor(.accentColor.opacity(habit.isComplete ? 1 : 0.5))
                    .scaleEffect(habit.score)
                    .overlay {
                        if habit.isComplete {
                            Image(systemName: "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                                .foregroundStyle(.thinMaterial)
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: habit.score)
            }
            .onTapGesture { habit.complete() }
            .frame(minHeight: 0, maxHeight: .infinity)
            
        }
        .overlay(alignment: .top) {
            VStack {
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
                Text(habit.title)
                    .font(Font.system(.largeTitle, design: .serif))
                if let dateStartedDescription = habit.dateStartedDescription {
                    Text(dateStartedDescription)
                        .font(Font.system(.subheadline, design: .serif))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("See more")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.gray.opacity(1/3))
                Image(systemName: "chevron.compact.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.gray.opacity(1/3))
            }
            
        }
        .padding(.horizontal, 40)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
        
        let dataManager = DataManager.preview
        
        ContentView(habit: Habit.makePreview(context: dataManager.container.viewContext))
    }
}
