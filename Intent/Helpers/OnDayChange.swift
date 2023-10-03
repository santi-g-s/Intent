//
//  OnDayChange.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 30/09/2023.
//

import Combine
import SwiftUI

struct OnDayChangeModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification).receive(on: DispatchQueue.main))
            { _ in
                print("Significant Time Change Notification")
                action()
            }
    }
}

extension View {
    func onDayChange(perform action: @escaping () -> Void) -> some View {
        modifier(OnDayChangeModifier(action: action))
    }
}
