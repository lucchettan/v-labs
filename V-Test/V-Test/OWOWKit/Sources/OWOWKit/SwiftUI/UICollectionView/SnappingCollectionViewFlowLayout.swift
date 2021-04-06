import UIKit

/// A collection view flow layout that snaps while scrolling.
open class SnappingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    /// When set to `true` (the default), a scale effect is applied to items that are not at the center.
    public var appliesScaleEffect = true
    
    /// Using this property, snapping can be disabled.
    public var isSnappingEnabled = true

    open override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        // A deceleration rate of "fast" provides a nice feel when using a paged interface.
        collectionView.decelerationRate = .fast
    }
    
    private lazy var lastContentOffset = self.collectionView?.contentOffset ?? .zero
    
    private func applyScale(attributes original: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard appliesScaleEffect, let collectionView = collectionView else {
            return original
        }
        
        let attributes = original.copy() as! UICollectionViewLayoutAttributes
        
        let horizontalCenter = collectionView.contentOffset.x + (collectionView.bounds.width / 2)
        let distanceFromCenterForMinimumScale = collectionView.bounds.width / 2
        let minimumScale: CGFloat = 0.95
        
        let distanceFromCenter = attributes.center.x - horizontalCenter
        let scale = max(minimumScale, 1 - ((abs(distanceFromCenter) / distanceFromCenterForMinimumScale) * (1 - minimumScale)))
        
        /// Apply a translation to the view so the interitemSpacing is always respected.
        let scaledWidth = scale * attributes.size.width
        let positionCorrection = CGFloat(
            signOf: -distanceFromCenter,
            magnitudeOf: (attributes.size.width - scaledWidth) / 2
        )
        
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: positionCorrection, y: 0)
        
        return attributes
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributeSets = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        return attributeSets.map(applyScale)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        return applyScale(attributes: attributes)
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard isSnappingEnabled, let collectionView = collectionView,
            let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds),
            !layoutAttributes.isEmpty else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let mid = collectionView.bounds.size.width / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x + (proposedContentOffset.x * velocity.x) + mid
        
        let closest = layoutAttributes.sorted {
            abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin)
        }.first!
        
        return CGPoint(
            x: floor(closest.center.x - mid),
            y: proposedContentOffset.y
        )
    }
    
}

