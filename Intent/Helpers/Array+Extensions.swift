//
//  Array+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 30/09/2023.
//

import Foundation

extension Array where Element: Comparable {
    mutating func insertInOrder(_ newElement: Element) {
        if let index = self.firstIndex(where: { $0 >= newElement }) {
            self.insert(newElement, at: index)
        } else {
            self.append(newElement)
        }
    }
}
