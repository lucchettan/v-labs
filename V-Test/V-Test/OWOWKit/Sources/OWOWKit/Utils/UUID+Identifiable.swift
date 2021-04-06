//
//  UUID+Identifiable.swift
//  Duco
//
//  Created by Robbert Brandsma on 27/01/2020.
//  Copyright © 2020 OWOW. All rights reserved.
//

import SwiftUI

extension UUID: Identifiable {
    public var id: UUID {
        self
    }
}
