//
//  PlaceholderHabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 31/12/2022.
//

import SwiftUI

struct PlaceholderHabitView: View {
    
    let timer = Timer.publish(every: 2, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    let symbols: [String] = {
        guard let path = Bundle.main.path(forResource: "sfsymbols", ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            return []
        }
        return content.replacingOccurrences(of: ".fill\n", with: "\n")
            .split(separator: "\n")
            .map { String($0)}
            .shuffled()
    }()
    
    @State var selection = 0
    
    var body: some View {
        VStack(spacing: 100){
            Spacer()
            TabView(selection: $selection) {
                ForEach(symbols.indices, id: \.self) { index in
                    Image(systemName: symbols[index])
                        .resizable()
                        .fontWeight(.light)
                        .foregroundStyle(.quaternary)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .tag(index)
                }
            }
            .frame(height: 100)
            
            HStack(alignment: .firstTextBaseline){
                Text("Tap ") + Text(Image(systemName: "plus.circle.fill")) + Text(" to create a new habit")
            }
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            Spacer()
            
        }
        .onReceive(timer) { time in
            withAnimation {
                if selection + 1 < symbols.count - 1 {
                    selection = selection + 1
                } else {
                    selection = 0
                }
            }
        }
    }
}

struct PlaceholderHabitView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderHabitView()
    }
}
