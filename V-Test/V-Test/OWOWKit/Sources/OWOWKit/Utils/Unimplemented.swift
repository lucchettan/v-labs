/// A helper function to use as a placeholder if a method isn't implemented yet.
///
/// ```
/// func calculateTheMeaningOfLife() -> MeaningOfLife {
///     unimplemented()
/// }
/// ```
@available(*, deprecated, message: "Pending implementation")
public func unimplemented(function: StaticString = #function) -> Never {
    fatalError("\(function) is pending implementation")
}
