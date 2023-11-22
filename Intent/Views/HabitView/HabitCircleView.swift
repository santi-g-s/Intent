//
//  HabitCircleView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 16/11/2023.
//

import SwiftUI
import CoreHaptics


struct HabitCircleView: View {
    
    @ObservedObject var habit: Habit
    var habitScore: Double
    
    @State private var engine: CHHapticEngine?
    
    @State private var bounce = false
    
    var partialCircleProgress: Double {
        let progress = Double(habit.completionsInPeriod)/Double(habit.requiredCount)
        return progress.isEqual(to: 0.0) ? 1.0 : progress
    }
    
    var availableWidth: CGFloat {
        max(0, (UIScreen.main.bounds.width - 2 * 40) * habitScore - 12)
    }
    
    var body: some View {
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
                    } else {
                        if habit.completionsInPeriod < habit.requiredCount {
                            Text("\(habit.completionsInPeriod) / \(habit.requiredCount)")
                                .font(Font.system(size: 20))
                                .foregroundStyle(.tertiary)
                        }
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
                PartialCircle(progress: partialCircleProgress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: partialCircleProgress)
                    .foregroundColor(habit.accentColor.opacity(habit.status != .pending(0) ? 1 : 2 / 3))
                    .shadow(color: habit.accentColor.adjust(brightness: -0.3).opacity(0.2), radius: habit.status != .pending(0) ? 16 : 0, x: 0, y: 0)
                    .scaleEffect(habitScore.rounded(toPlaces: 3).roundedUp(toNearest: 0.1))
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
                                if !habitScore.isEqual(to: 0.0) {
                                    Text("\(score) / \(habit.requiredCount)")
                                        .font(Font.system(size: 20))
                                        .foregroundStyle(.tertiary)
                                        .colorScheme(habit.accentColor.isDarkBackground() ? .dark : .light)
                                }
                            }
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: bounce)
                    .onChange(of: habit.completionsInPeriod) { _ in
                        bounce.toggle() // this will trigger the bounce animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            bounce = false
                        }
                    }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .onAppear {
            prepareHaptics()
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
}

struct HabitCircleView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.preview
        HabitCircleView(habit: Habit.makePreview(context: dataManager.container.viewContext), habitScore: 0.4)
            .padding()
    }
}
