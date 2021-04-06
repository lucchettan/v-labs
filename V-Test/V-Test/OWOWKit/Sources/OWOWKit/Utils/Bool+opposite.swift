//
//  Bool+opposite.swift
//  Duco
//
//  Created by Robbert Brandsma on 24/01/2020.
//  Copyright © 2020 OWOW. All rights reserved.
//

import Foundation

extension Bool {
    /// Equal to using the `!` operator, but useful for creating bindings etc.
    @inlinable
    public var opposite: Bool {
        get {
            return !self
        }
        set {
            self = !newValue
        }
    }
}
