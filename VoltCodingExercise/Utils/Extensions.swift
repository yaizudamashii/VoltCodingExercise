//
//  Extensions.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit

protocol OptionalString {}
extension String: OptionalString {}

extension Optional where Wrapped: OptionalString {
    var isNilOrEmpty: Bool {
        return ((self as? String) ?? "").isEmpty
    }
}

extension Set {
    func isEqualToSet(otherSet : Set<Element>) -> Bool {
        if (self.count != otherSet.count) {
            return false
        }
        for element in otherSet {
            if (!self.contains(element)) {
                return false
            }
        }
        return true
    }
}