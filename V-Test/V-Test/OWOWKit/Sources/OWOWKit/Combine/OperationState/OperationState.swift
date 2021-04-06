import Combine

/// Describes the progress of an operation.
///
/// The purpose of  `OperationState` (and it's simpler variant, `ProgressState`) is to make
/// it easier to present asynchronous operations in the user interface.
///
/// Example usage:
///
/// ```
/// // In ViewModel:
///
/// someOperation()
///     .toOperationState()
///     .weakAssign(to: \.state, on: self)
///
/// // In View:
///
/// if viewModel.state.isLoading {
///     FancyLoadingView()
/// }
///
/// viewModel.state.result.map(ViewUsingResult.init)
/// viewModel.state.error.map(ErrorView.init)
/// ```
///
public enum OperationState<Result, Failure: Error> {
    /// The neutral state of an operation.
    case normal
    
    /// The operation is currently in progress.
    case inProgress
    
    /// The operation has successfully completed.
    case finished(Result)
    
    /// The operation has failed because of an error.
    case error(Failure)
    
    // MARK: Accessing the operation attributes
    
    /// `true` if the operation is currently in progress.
    public var isInProgress: Bool {
        if case .inProgress = self {
            return true
        }
        
        return false
    }
    
    /// `true` if the operation is finished.
    public var isFinished: Bool {
        if case .finished = self {
            return true
        }
        
        return false
    }
    
    /// `true` if an error occurred.
    public var isError: Bool {
        if case .error = self {
            return true
        }
        
        return false
    }
    
    /// `true` if the state of the operation is currently `normal`.
    public var isNormal: Bool {
        if case .normal = self {
            return true
        }
        
        return false
    }
    
    /// If the operation has failed, returns the error that caused the operation to fail. Otherwise, returns `nil`.
    ///
    /// Setting this property to `nil` causes the operation state to become `normal`.
    /// Setting any other value causes the operation state to become `.error(newValue)`.
    ///
    /// This property may be useful to use the error as a binding with a SwiftUI view, for example, allowing the
    /// user to reset the state to `normal` after dismissing the error.
    public var error: Failure? {
        get {
            if case .error(let error) = self {
                return error
            }
            
            return nil
        }
        set {
            if let newValue = newValue {
                self = .error(newValue)
            } else {
                self = .normal
            }
        }
    }
    
    /// If the operation has succeeded, returns the result of the operation.
    ///
    /// Setting this property to `nil` causes the operation state to become `normal`.
    /// Setting any other value causes the operation state to become `.finished(newValue)`.
    ///
    /// This property may be useful to bind the result of the operation as a value to a SwiftUI view.
    public var result: Result? {
        get {
            if case .finished(let result) = self {
                return result
            }
            
            return nil
        }
        set {
            if let newValue = newValue {
                self = .finished(newValue)
            } else {
                self = .normal
            }
        }
    }
    
    /// Returns `self` converted to `ProgressState` (a.k.a. `OperationState<Void, Error>`).
    public var progress: ProgressState {
        switch self {
        case .normal:
            return .normal
        case .inProgress:
            return .inProgress
        case .finished:
            return .finished
        case .error(let error):
            return .error(error)
        }
    }
}

