import SwiftUI

/// A view that acts like a sort of  `switch` on an `OperationState`.
@available(iOS 13, tvOS 13, *)
public struct OperationStateView<Result, Failure: Error, NormalView: View, InProgressView: View, ErrorView: View, FinishedView: View>: View {
    
    public typealias State = OperationState<Result, Failure>
    
    // MARK: Configuration
    
    private var view: AnyView
    
    // MARK: Init
    
    public init(
        state: State,
        normalView: @autoclosure () -> NormalView,
        loadingView: @autoclosure () -> InProgressView,
        @ViewBuilder errorView: (Failure) -> ErrorView,
        @ViewBuilder finishedView: (Result) -> FinishedView
    ) {
        switch state {
        case .normal:
            view = normalView()
                .erasedToAnyView()
        case .inProgress:
            view = loadingView()
                .erasedToAnyView()
        case .error(let error):
            view = errorView(error)
                .erasedToAnyView()
        case .finished(let result):
            view = finishedView(result)
                .erasedToAnyView()
        }
    }
    
    // MARK: View
    
    public var body: some View {
        view
    }
}

@available(iOS 13, tvOS 13, *)
public struct _ErrorShowingView<Failure: Error>: View {
    @State var error: Failure?
    
    init(error: Failure) {
        self.error = error
    }
    
    public var body: some View {
        Image(systemName: "exclamationmark.triangle")
            .showErrors(error: $error)
    }
}

@available(iOS 13, tvOS 13, *)
public extension OperationStateView where NormalView == EmptyView, ErrorView == _ErrorShowingView<Failure>, InProgressView == AnyView {
    
    init(state: State, @ViewBuilder finishedView: (Result) -> FinishedView) {
        self.init(
            state: state,
            normalView: EmptyView(),
            loadingView: EmptyView()
                .erasedToAnyView(),
            errorView: { _ErrorShowingView(error: $0) },
            finishedView: finishedView
        )
    }
    
}
