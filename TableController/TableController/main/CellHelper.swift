import Foundation
import UIKit

public protocol DecorationCellHelper { }

public protocol CellHelper: class {

    var precalculatedLayoutSize: CGSize? { get }
    func estimatedHeight(indexPath: IndexPath, width: CGFloat) -> CGFloat
    func precalculateLayout(indexPath: IndexPath, width: CGFloat)
    func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath?
    func willDisplayAtIndexPath(_ indexPath: IndexPath)
    func isEqual(to cellHelper: CellHelper) -> Bool
    func clearCache()

    func createCellView(width: CGFloat) -> UIView
    func reuseCellView(_ cellView: UIView) -> Bool
    func updateViewState() -> Bool

    func updateBy(_ cellHelper: CellHelper) -> Bool

    var setupInitialCollectionAttributesForAppearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)? { get }
    var setupFinalCollectionAttributesForDisappearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)? { get }
    var setupDefaultCollectionAttributes: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)? { get }
}

extension CellHelper {

    public func reuseCellView(_ cellView: UIView) -> Bool {
        return false
    }
    
    public func updateViewState() -> Bool {
        return false
    }

    public func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    public func willDisplayAtIndexPath(_ indexPath: IndexPath) {        
    }

    public func topSeparatorEdgeInsets(indexPath: IndexPath) -> UIEdgeInsets? {
        return nil
    }

    public func bottomSeparatorEdgeInsets(indexPath: IndexPath) -> UIEdgeInsets? {
        return nil
    }

    public func isEqual(to cellHelper: CellHelper) -> Bool {
        return cellHelper === self
    }

    public func updateBy(_ cellHelper: CellHelper) -> Bool {
        return false
    }
    
    public var setupInitialCollectionAttributesForAppearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)? {
        get {
            return nil
        }
    }
    
    public var setupFinalCollectionAttributesForDisappearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)? {
        get {
            return nil
        }
    }
    
    public var setupDefaultCollectionAttributes: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)? {
        get {
            return nil
        }
    }
    
    public func clearCache() {
    }
}
