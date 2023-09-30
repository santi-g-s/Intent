//
//  NumericTextField.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 29/09/2023.
//

import SwiftUI

struct NumericTextField: View {
    @Binding var value: String

    var body: some View {
        TextField("0", text: $value, onCommit: {
            filterNumeric()
        })
        .keyboardType(.numberPad)
        .onChange(of: value) { _ in
            filterNumeric()
        }
    }

    func filterNumeric() {
        value = String(value.filter { "0123456789".contains($0) })
    }
}


struct NumericTextField_Previews: PreviewProvider {
    static var previews: some View {
        NumericTextField(value: .constant(""))
    }
}
