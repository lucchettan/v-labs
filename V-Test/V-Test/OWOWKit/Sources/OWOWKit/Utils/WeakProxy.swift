/// A type that functions as a proxy to `Object`. It maintains a weak refrence to the object.
///
/// Through dynamic member lookup, it provides access to the properties of the underlying object. After the object is deallocated, all future operations return `nil`.
@dynamicMemberLookup
public struct WeakProxy<Object> where Object: AnyObject {
    public private(set) weak var object: Object?
    
    public init(_ wrappedValue: Object) {
        self.object = wrappedValue
    }
    
    public subscript<Value>(keyPath: KeyPath<Object, Value>) -> Value? {
        return object?[keyPath: keyPath]
    }
    
    public subscript<Value>(keyPath: ReferenceWritableKeyPath<Object, Value>) -> Value? {
        get {
            return object?[keyPath: keyPath]
        }
        nonmutating set {
            if let value = newValue {
                object?[keyPath: keyPath] = value
            }
        }
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<Object, Value>) -> Value? {
        return object?[keyPath: keyPath]
    }
    
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, Value>) -> Value? {
        get {
            return object?[keyPath: keyPath]
        }
        nonmutating set {
            if let value = newValue {
                object?[keyPath: keyPath] = value
            }
        }
    }
}
