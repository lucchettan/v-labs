//
//  URLButton.swift
//  Duco
//
//  Created by Robbert Brandsma on 30/01/2020.
//  Copyright © 2020 OWOW. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 13, *)
public struct URLButton<Label: View>: View {
    private var button: Button<Label>
    
    public init(url: URL, @ViewBuilder label: () -> Label) {
        self.button = Button(action: {
            UIApplication.shared.open(url)
        }, label: label)
    }
    
    public var body: some View {
        button
    }
}
