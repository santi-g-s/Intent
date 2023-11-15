//
//  PartialCircle.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 11/11/2023.
//

import SwiftUI

struct PartialCircle: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let startAngle = Angle(degrees: -90)
            let endAngle = Angle(degrees: -90 + (360 * Double(progress)))

            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.closeSubpath()
        }
    }
}
