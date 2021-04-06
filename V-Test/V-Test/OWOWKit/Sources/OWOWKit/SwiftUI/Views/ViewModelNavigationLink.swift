//
//  ViewModelNavigationLink.swift
//  Home Control
//
//  Created by Robbert Brandsma on 17/11/2020.
//  Copyright © 2020 OWOW. All rights reserved.
//

import SwiftUI

/// A navigation link whose destination is a product of an external view model.
@available(iOS 13, *)
public struct ViewModelNavigationLink<ViewModel, Label, Destination>: View where Label: View, Destination: View {
    @Binding private var viewModel: ViewModel?
    private var destination: (ViewModel) -> Destination
    private var navigate: () -> Void
    private var label: Label
    
    /// 🌷
    /// - Parameters:
    ///   - viewModel: A binding to the view model.
    ///   - destination: A closure that produces the destination view as a product of the view model.
    ///   - navigate: A closure that is expected to initialise a view model and make it available to the `viewModel` binding.
    ///   - label: A view describing the purpose of the link.
    public init(viewModel: Binding<ViewModel?>, destination: @escaping (ViewModel) -> Destination, navigate: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self._viewModel = viewModel
        self.destination = destination
        self.navigate = navigate
        self.label = label()
    }
    
    public var body: some View {
        Button(action: navigate) { label }
            .background(
                NavigationLink(
                    destination: navigationDestination,
                    isActive: navigationDestinationIsActive,
                    label: {
                        EmptyView()
                    })
                    .hidden()
                )
    }
    
    private var navigationDestination: AnyView {
        if let viewModel = viewModel {
            return destination(viewModel).erasedToAnyView()
        } else {
            return EmptyView().erasedToAnyView()
        }
    }
    
    private var navigationDestinationIsActive: Binding<Bool> {
        Binding(
            get: { viewModel != nil },
            set: { newValue in
                if newValue == true && viewModel == nil {
                    self.navigate()
                } else if newValue == false && viewModel != nil {
                    viewModel = nil
                }
            })
    }
}
