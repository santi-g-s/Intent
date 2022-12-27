//
//  AddHabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 25/12/2022.
//

import SwiftUI

struct AddHabitView: View {
    
    @State var title = ""
    @State var timePeriod = TimePeriod.daily
    @State var requiredCount = 0
    @State var color = Color.accentColor
    @State var showSymbolPicker = false
    @State var symbolName = "star"
    @State var messageText = ""
    @State var messages = [String]()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    Button {
                        showSymbolPicker = true
                    } label: {
                        HStack{
                            Text("Pick an icon")
                            Spacer()
                            Image(systemName: symbolName)
                        }
                        .foregroundColor(.primary)
                    }

                    ColorPicker("Pick a color", selection: $color)
                }
                
                Section("Scheduling") {
                    Picker("How often", selection: $timePeriod) {
                        Text("Daily").tag(TimePeriod.daily)
                        Text("Weekly").tag(TimePeriod.weekly)
                        Text("Monthly").tag(TimePeriod.monthly)
                    }
                    .pickerStyle(.segmented)
                    Picker("How many times a \(timePeriod.unitName)", selection: $requiredCount) {
                        ForEach(0..<5, id: \.self) { index in
                            Text("\(index+1)")
                        }
                    }
                }
                
                Section("Messages") {
                    VStack(alignment: .leading){
                        TextField("Add a motivational message", text: $messageText, axis: .vertical)
                        Button {
                            messages.append(messageText)
                            messageText = ""
                        } label: {
                            HStack{
                                Spacer()
                                Text("Add")
                                Image(systemName: "plus.circle.fill")
                            }
                            
                        }
                        .disabled(messageText == "")
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            return 0
                        }
                        
                    }
                    
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                    }
                    .onDelete { indexSet in
                        messages.remove(atOffsets: indexSet)
                    }
                    
                }
            }
            .navigationTitle("Add a habit")
            .safeAreaInset(edge: .bottom) {
                Button {
                    //
                } label: {
                    Label("Create habit", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)

            }
        }
        .sheet(isPresented: $showSymbolPicker) {
            SymbolPicker(symbol: $symbolName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
