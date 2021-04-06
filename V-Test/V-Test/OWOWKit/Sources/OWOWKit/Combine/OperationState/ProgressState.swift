/// A simpler variant of `OperationState`, usable for views that may be interested in the progress of an operation, but not in the type of that operation.
public typealias ProgressState = OperationState<Void, Error>

public extension ProgressState {
    static var finished: Self {
        .finished(())
    }
    
    var isFinished: Bool {
        get {
            if case .finished = self {
                return true
            } else {
                return false
            }
        }
        set {
            if newValue {
                self = .finished
            } else {
                self = .normal
            }
        }
    }
}

