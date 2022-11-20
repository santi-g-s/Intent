//
//  Double+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 19/11/2022.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
