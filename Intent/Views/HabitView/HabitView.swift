//
//  HabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import CoreHaptics
import SwiftUI

struct HabitView: View {
    @ObservedObject var habit: Habit
    
    @Binding var habitEditorConfig: HabitEditorConfig
    
    @State var habitScore = 0.5
    @State var completionMap = [Date: Int]()
    
    @State var showDetail = false
    @State var scrollOffset: CGPoint = .zero
    
    @State var returnToTop = false
    
    @State private var engine: CHHapticEngine?
    
    @State private var presentEditHabit = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text(habit.title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(Font.system(.largeTitle, design: .rounded, weight: .bold))
                .onTapGesture {
                    returnToTop.toggle()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .scaleEffect(max(2/3, min((250 + scrollOffset.y)/250, 1.2)), anchor: .top)
                .padding(.top, 4)
            
            GeometryReader { geoReader in
                ScrollViewReader { proxy in
                    ScrollViewOffset(
                        axes: [.vertical],
                        showsIndicators: false,
                        offsetChanged: { offset in
                            self.scrollOffset = offset
                            if showDetail == false {
                                if offset.y < -110 {
                                    showDetail = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                        scrollHaptic()
                                    }
                                } else if offset.y > 120 {
                                    habitEditorConfig.isGroupViewShown = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            proxy.scrollTo("top", anchor: .top)
                                        }
                                        scrollHaptic()
                                    }
                                }
                            } else {
                                if offset.y > -20 {
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
            prepareHaptics()
            withAnimation(.none) {
                habitScore = habit.calculateScore()
                completionMap = habit.calculateCompletionMap()
            }
        }
        .onChange(of: habit.completedDates) { _ in
            habitScore = habit.calculateScore()
            completionMap = habit.calculateCompletionMap()
            print(habitScore)
        }
        .onDayChange {
            habitScore = habit.calculateScore()
            completionMap = habit.calculateCompletionMap()
        }
        .overlay(alignment: .bottom) {
            HStack {
                Spacer()
                Button {
                    habitEditorConfig.presentEditHabit(habit: habit)
                    presentEditHabit = true
                } label: {
                    Label("Edit", systemImage: "slider.vertical.3")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundStyle(.regularMaterial))
                }
            }
            .padding(.horizontal)
            .disabled(!showDetail)
            .opacity(min(1, -scrollOffset.y/(UIScreen.main.bounds.height - 200)))
        }
        .sheet(isPresented: $presentEditHabit, onDismiss: {
            habitScore = habit.calculateScore()
            completionMap = habit.calculateCompletionMap()
        }) {
            HabitEditorView(config: $habitEditorConfig)
        }
    }
    
    var partialCircleProgress: Double {
        let progress = Double(habit.completionsInPeriod)/Double(habit.requiredCount)
        return progress.isEqual(to: 0.0) ? 1.0 : progress
    }
    
    var content: some View {
        VStack {
            HabitCircleView(habit: habit, habitScore: habitScore)
            .frame(minHeight: 0, maxHeight: .infinity)
        }
        .padding(.horizontal, 40)
        .overlay(alignment: .top) {
            VStack {
                VStack {
                    Text("Swipe down to manage habits")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray.opacity(1/3))
                    
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .foregroundColor(.gray.opacity(1/3))
                    
                }.padding(.top, -60)
                
                if let leadingDesc = habit.leadingStreakDescription, let numDays = habit.streakDescriptionsNumDays, let trailingDesc = habit.trailingStreakDescription {
                    HStack(spacing: 4) {
                        Text(leadingDesc)
                            .foregroundStyle(.secondary)
                        Text(String(numDays))
                            .bold()
                            .foregroundColor(habit.accentColor)
                            .padding(4)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).foregroundColor(habit.accentColor).opacity(0.1))
                        Text(trailingDesc)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
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
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .bottom) {
                    HStack(alignment: .bottom) {
                        Text("\(habit.completionsInPeriod) / \(habit.requiredCount)")
                            .font(.system(.body, design: .rounded, weight: .bold))
                            .foregroundColor(habit.accentColor)
                            .padding(16)
                            .background(Circle().foregroundStyle(.regularMaterial))
                        
                        Spacer()
                        
                        Spacer()
                        
                        if habit.status != .pending(0) {
                            Button {
                                habit.revertCompletion()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Circle().foregroundStyle(.regularMaterial))
                                    .padding(.trailing, 6)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func scrollHaptic() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.preview
        
        HabitView(habit: Habit.makePreview(context: dataManager.container.viewContext), habitEditorConfig: .constant(HabitEditorConfig()))
    }
}
