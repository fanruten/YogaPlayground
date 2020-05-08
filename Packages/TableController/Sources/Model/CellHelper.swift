import Foundation
import UIKit

public class CollectionViewCellAttributes {
    var setupInitialCollectionAttributesForAppearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)?
    var setupFinalCollectionAttributesForDisappearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)?
    var setupDefaultCollectionAttributes: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)?
}

public protocol CellHelper: class {
    /// Create view. It is assumed that `createCellView` can return same view for different calls
    func createCellView(width: CGFloat) -> UIView
    
    /// May be called on background. Should calcualte cell size and set `precalculatedLayoutSize` property
    func precalculateLayout(indexPath: IndexPath, width: CGFloat)
    
    /// Precalculated size of cell. Calculated by `precalculateLayout` call
    var precalculatedLayoutSize: CGSize? { get }
    
    /// Used by auto-dffing algorithm to understand necessity of cell update
    func isEqual(to cellHelper: CellHelper) -> Bool
        
    /// On refresh old cell replaced by new. This method allow leave old one
    /// May be used in cases when cell caches view returned by `createCellView`
    func updateBy(_ cellHelper: CellHelper) -> Bool
    
    /// `UICollectionViewLayoutAttributes` for customization cell position. Commonly used to set z-index
    var collectionViewCellAttributes: CollectionViewCellAttributes? { get }
}

extension CellHelper {    
    public func isEqual(to cellHelper: CellHelper) -> Bool {
        return cellHelper === self
    }

    public func updateBy(_ cellHelper: CellHelper) -> Bool {
        return false
    }
    
    public var collectionViewCellAttributes: CollectionViewCellAttributes? {
        get {
            return nil
        }
    }
}
