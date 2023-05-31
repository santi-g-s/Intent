//
//  Button+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 31/12/2022.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.45, blendDuration: 0), value: configuration.isPressed)
    }
}
