/// A criteria that can be used to filter models.
public protocol Criteria {
    /// If `true`, multiple instances of the criteria can be added at the same time.
    /// If set to false, any other instance of the criteria will be removed when adding a new instance.
    var multipleInstancesAllowed: Bool { get }
}
