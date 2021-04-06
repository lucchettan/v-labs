import Foundation
import Combine

@available(iOS 13, *)
extension Future {
    /// Converts the legacy OWOWKit future to an Apple Combine future.
    /// - Returns: A Combine future.
    public func toCombine() -> Combine.Future<Value, Error> {
        return Combine.Future { fulfill in
            self.whenComplete(fulfill)
        }
    }
}
