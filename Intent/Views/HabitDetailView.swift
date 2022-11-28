//
//  HabitDetailView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI

struct HabitDetailView: View {
    var body: some View {
        VStack {
            VStack {
                Text("See more")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.gray.opacity(1/3))
                Image(systemName: "chevron.compact.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.gray.opacity(1/3))
            }
            .padding(.top)
            
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.secondaryBgColor.edgesIgnoringSafeArea(.all))
    }
}

struct HabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HabitDetailView()
    }
}
