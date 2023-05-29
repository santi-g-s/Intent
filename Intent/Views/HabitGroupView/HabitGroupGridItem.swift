//
//  HabitGroupGridItem.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/05/2023.
//

import SwiftUI

struct HabitGroupGridItem: View {
    
    @State var habitScore = 0.0
    @State var size = CGSize.zero
    var habit: Habit
    
    var body: some View {
        VStack(alignment: .leading){
            Image(systemName: habit.iconName)
                .imageScale(.large)
                .foregroundStyle(.primary)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading){
                Text(habit.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.system(.body, design: .rounded))
                Text(habit.streakDescription)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .readSize { size in
            self.size = size
        }
        .background(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: self.size.width * habitScore)
                .foregroundColor(habit.accentColor.opacity(habit.status == .complete ? 1 : 0.75))
                .shadow(radius: 8)
                .opacity(0.4)
                
                
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(Color(UIColor.secondarySystemBackground)))
        .onAppear {
            withAnimation(.none){
                habitScore = habit.calculateScore()
            }
        }
        
    }
}

struct HabitGroupGridItem_Previews: PreviewProvider {
    
    static var previews: some View {
        let dataManager = DataManager.preview
        
        return HabitGroupGridItem(habit: Habit.makePreview(context: dataManager.container.viewContext))
    }
}
