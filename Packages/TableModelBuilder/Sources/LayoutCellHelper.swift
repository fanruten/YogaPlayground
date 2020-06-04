import TableController
import YogaLayout
import UIKit

open class LayoutCellHelper<Model>: CellHelper where Model: Equatable {
    public typealias LayoutCreator<Model> = (Model) -> Layout
    public typealias WidthDependentLayoutCreator<Model> = (Model, CGFloat) -> Layout
    
    enum LayoutCreatorType<Model> {
        case basic(LayoutCreator<Model>)
        case widthDependent(WidthDependentLayoutCreator<Model>)
    }

    private let layoutCreator: LayoutCreatorType<Model>
    private let model: Model
    private var widthCache: CGFloat?
    private var layoutCache: Layout?

    private func layout(for width: CGFloat) -> Layout {
        switch self.layoutCreator {
        case let .basic(creator):
            if let cachedLayout = layoutCache {
                return cachedLayout
            }
            let layout = creator(self.model)
            layoutCache = layout
            return layout
        case let .widthDependent(creator):
            if widthCache == width,
                let cachedLayout = layoutCache {
                return cachedLayout
            }
            let layout = creator(self.model, width)
            layoutCache = layout
            widthCache = width
            return layout
        }
    }

    private var creator: BasicViewHierarchyCreator?

    public init(model: Model, layoutCreator: @escaping LayoutCreator<Model>) {
        self.model = model
        self.layoutCreator = .basic(layoutCreator)
    }
    
    public init(model: Model, widthDependentLayoutCreator: @escaping WidthDependentLayoutCreator<Model>) {
        self.model = model
        self.layoutCreator = .widthDependent(widthDependentLayoutCreator)
    }
    
    public var precalculatedLayoutSize: CGSize? {
        return creator?.viewSize
    }

    public func estimatedHeight(indexPath: IndexPath, width: CGFloat) -> CGFloat {
        return 0
    }

    public func createCellView(width: CGFloat) -> UIView {
        if creator == nil {
            creator = BasicViewHierarchyCreator(rootComponent: layout(for: width), boundingSize: CGSize(width: width, height: CGFloat.nan))
        }
        let layoutView = creator?.createView() ?? UIView(frame: .zero)
        return layoutView
    }

    public func precalculateLayout(indexPath: IndexPath, width: CGFloat) {
        creator = BasicViewHierarchyCreator(rootComponent: layout(for: width), boundingSize: CGSize(width: width, height: CGFloat.nan))
        creator?.calculateLayoutIfNeeded()
    }

    public func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    open func isEqual(to cellHelper: CellHelper) -> Bool {
        guard let typedCellHelper = cellHelper as? LayoutCellHelper else {
            return false
        }
        switch layoutCreator {
        case .basic(_):
            return model == typedCellHelper.model
        case .widthDependent(_):
            return model == typedCellHelper.model && widthCache == typedCellHelper.widthCache
        }
    }
}
