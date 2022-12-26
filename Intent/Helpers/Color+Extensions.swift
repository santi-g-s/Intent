//
//  Color+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/11/2022.
//

import SwiftUI

extension Color {
    static var secondaryBgColor: Color {
        return Color("secondaryBgColor")
    }
    
    static func random() -> Color {
        return Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}
