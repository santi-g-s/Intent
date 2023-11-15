//
//  Double+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 19/11/2022.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func roundedUp(toNearest resolution: Double) -> Double {
        guard resolution > 0 else { return self }
        return ceil(self / resolution) * resolution
    }

    func approximatelyIsMultipleOf(_ multiple: Double) -> Bool {
        let remainder = self.truncatingRemainder(dividingBy: multiple)
        return remainder < multiple * 0.1 || remainder > multiple * 0.9
    }

    var decimalPart: Double {
        return self - Double(Int(self))
    }
}
