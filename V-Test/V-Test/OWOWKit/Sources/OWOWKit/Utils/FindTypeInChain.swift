//
//  FindTypeInChain.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 21/08/2019.
//

/// Walks the given chain of values on `keyPath` until it finds a value of `type`, starting at `start`.
///
/// An example usage of this could be finding a certain type of superview of a view:
///
/// ```
/// return findTypeInChain(
///     startingAt: self,
///     keyPath: \.superview,
///     lookingForType: UIImageView.self
/// )
/// ```
public func findTypeInChain<ChainElement, SearchTarget>(
    startingAt start: ChainElement,
    keyPath: KeyPath<ChainElement, ChainElement?>,
    lookingForType type: SearchTarget.Type
) -> SearchTarget? {
    var current = start[keyPath: keyPath]
    while let candidate = current {
        if let candidate = candidate as? SearchTarget {
            return candidate
        }
        
        current = candidate[keyPath: keyPath]
    }
    
    return nil
}

/// Walks the given chain of sequences of values on `keyPath` until it finds a value of `type`, starting at `start`.
///
/// An example usage of this could be finding a certain type of subview of a view:
///
/// ```
/// return findTypeInChain(
///     startingAt: self,
///     keyPath: \.subviews,
///     lookingForType: UIImageView.self
/// )
/// ```
public func findTypeInChain<S: Sequence, ChainElement, SearchTarget>(
    startingAt start: ChainElement,
    keyPath: KeyPath<ChainElement, S>,
    lookingForType type: SearchTarget.Type
    ) -> SearchTarget? where S.Element == ChainElement {
    for candidate in start[keyPath: keyPath] {
        if let candidate = candidate as? SearchTarget {
            return candidate
        }
        
        if let nestedCandidate = findTypeInChain(startingAt: candidate, keyPath: keyPath, lookingForType: type) {
            return nestedCandidate
        }
    }
    
    return nil
}
