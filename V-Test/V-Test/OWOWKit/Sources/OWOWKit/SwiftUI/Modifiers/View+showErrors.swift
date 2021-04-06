//
//  File.swift
//  
//
//  Created by Robbert Brandsma on 27/04/2020.
//

import SwiftUI

/// A modifier to show errors from the given binding.
/// When the error is dismissed, the binding will be reset to `nil`, similar to an alert with an item.
/// The presentation of errors is configurable through `OWOWKitConfiguration.swiftUIErrorPresenter`.
@available(iOS 13, tvOS 13, *)
extension View {
    public func showErrors<Failure: Error>(error: Binding<Failure?>) -> some View {
        modifier(ShowErrorsModifier(error: error))
    }
}

@available(iOS 13, tvOS 13, *)
fileprivate struct ShowErrorsModifier<Failure: Error>: ViewModifier {
    @Binding var error: Failure?
    
    var isPresentedBinding: Binding<Bool> {
        Binding(
            get: { self.error != nil },
            set: { newValue in
                if newValue == false {
                    self.error = nil
                }
            })
    }
    
    func body(content: Content) -> some View {
        Group {
            if error == nil {
                content
            } else {
                error.map { errorBody(content: content, error: $0) }
            }
        }
    }
    
    func errorBody(content: Content, error: Failure) -> some View {
        return OWOWKitConfiguration.swiftUIErrorPresenter(
            content.erasedToAnyView(),
            error,
            isPresentedBinding
        )
    }
}
