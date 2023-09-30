//
//  OnDayChange.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 30/09/2023.
//

import Combine
import SwiftUI

struct OnDayChangeModifier: ViewModifier {
    @State private var currentDay: Int = Calendar.current.component(.day, from: Date())
    @State private var cancellable: AnyCancellable?
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                setupDayChangeWatcher()
            }
            .onDisappear {
                // Clean up when the view disappears
                self.cancellable?.cancel()
            }
    }

    func setupDayChangeWatcher() {
        // Calculate seconds until next midnight
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        guard let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) else { return }
        let timeUntilMidnight = nextMidnight.timeIntervalSince(now)

        // Set a timer to fire at next midnight
        let timer = Timer.publish(every: timeUntilMidnight, on: .main, in: .common).autoconnect()

        cancellable = timer.sink { _ in
            // Day has changed!
            self.currentDay = Calendar.current.component(.day, from: Date())
            self.action()
        }
    }
}

extension View {
    func onDayChange(perform action: @escaping () -> Void) -> some View {
        modifier(OnDayChangeModifier(action: action))
    }
}
