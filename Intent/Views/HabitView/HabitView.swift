//
//  HabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI
import CoreHaptics

struct HabitView: View {
    
    @ObservedObject var habit: Habit
    
    @Binding var habitEditorConfig: HabitEditorConfig
    
    @State var habitScore = 0.5
    @State var completionMap = [Date : Int]()
    
    @State var showDetail = false
    @State var scrollOffset: CGPoint = .zero
    
    @State var returnToTop = false
    
    @State private var engine: CHHapticEngine?
    
    @State private var presentEditHabit = false
    
    @State private var bounce = false
    
    var availableWidth: CGFloat {
        max(0,(UIScreen.main.bounds.width - 2*40) * habitScore - 12)
    }
    
    var body: some View {
        VStack(spacing: 0){
            Text(habit.title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(Font.system(.largeTitle, design: .rounded, weight: .bold))
                .onTapGesture {
                    returnToTop.toggle()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .scaleEffect(max(2/3, min((250+scrollOffset.y) / 250, 1.2)), anchor: .top)
                .padding(.top, 4)
            
            GeometryReader { geoReader in
                ScrollViewReader { proxy in
                    ScrollViewOffset(
                        axes: [.vertical],
                        showsIndicators: false,
                        offsetChanged: { offset in
                            self.scrollOffset = offset
                            if showDetail == false {
                                if (offset.y < -110) {
                                    showDetail = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01){
                                        withAnimation(.easeInOut(duration: 0.1)){
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                        scrollHaptic()
                                        
                                    }
                                } else if (offset.y > 120) {
                                    habitEditorConfig.isGroupViewShown = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01){
                                        withAnimation(.easeInOut(duration: 0.1)){
                                            proxy.scrollTo("top", anchor: .top)
                                        }
                                        scrollHaptic()
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
            prepareHaptics()
            withAnimation(.none){
                habitScore = habit.calculateScore()
                completionMap = habit.calculateCompletionMap()
            }
        }
        .onChange(of: habit.completedDates) { _ in
            habitScore = habit.calculateScore()
            completionMap = habit.calculateCompletionMap()
        }
        .overlay(alignment: .bottom){
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
            .opacity(min(1, -scrollOffset.y/(UIScreen.main.bounds.height-200)))
        }
        .sheet(isPresented: $presentEditHabit, onDismiss: {
            habitScore = habit.calculateScore()
            completionMap = habit.calculateCompletionMap()
        }) {
            HabitEditorView(config: $habitEditorConfig)
        }
    }
    
    var content: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundStyle(.regularMaterial)
                    .onTapGesture {
                        habit.complete()
                        if habit.status == .complete {
                            completionHaptic()
                        } else {
                            tapHaptic()
                        }
                    }
                    .overlay {
                        if habitScore.isEqual(to: 0.0) {
                            Text("Tap to log your habit")
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                
                Button {
                    habit.complete()
                    if habit.status == .complete {
                        completionHaptic()
                    } else {
                        tapHaptic()
                    }
                } label: {
                    Circle()
                        .foregroundColor(habit.accentColor.opacity(habit.status == .complete ? 1 : 0.75))
                        .shadow(color: habit.accentColor.adjust(brightness: -0.3).opacity(0.2), radius: habit.status == .complete ? 16 : 0, x: 0, y: 0)
                        .scaleEffect(habitScore)
                        .scaleEffect(bounce ? 1.1 : 1)
                        .overlay {
                            Group {
                                switch habit.status {
                                case .complete:
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: min(availableWidth, 30))
                                        .foregroundStyle(.tertiary)
                                        .colorScheme(habit.accentColor.isDarkBackground() ? .dark : .light)
                                case .pending(let score):
                                    if score != 0 {
                                        Text("\(score) / \(habit.requiredCount)")
                                            .font(Font.system(size: 20))
                                            .foregroundStyle(.tertiary)
                                            .colorScheme(habit.accentColor.isDarkBackground() ? .dark : .light)
                                    }
                                }
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: bounce)
                        .onChange(of: habit.completionsInPeriod) { newValue in
                            bounce.toggle()  // this will trigger the bounce animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                bounce = false
                            }
                        }
                }
                .buttonStyle(ScaleButtonStyle())
            }
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
                
                
                if let dateStartedDescription = habit.streakDescription {
                    Text(dateStartedDescription)
                        .font(.subheadline)
                        .foregroundColor(habit.accentColor)
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
                    HStack(alignment: .bottom){
                        
                        Text("\(habit.completionsInPeriod) / \(habit.requiredCount)")
                            .font(.system(.body, design: .rounded, weight: .bold))
                            .foregroundColor(habit.accentColor)
                            .padding(16)
                            .background(Circle().foregroundStyle(.regularMaterial))
                            .scaleEffect(bounce ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: bounce)
                        
                        
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
    
    func tapHaptic() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
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
    
    func completionHaptic() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.15)
        events.append(event2)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
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
