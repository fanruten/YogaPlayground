import UIKit
import YogaLayout
import Yoga
import YogaSwift
import TableController
import UIUtils

final class SimpleTableModelBuilder: BaseTableModelBuilder {
    
    /*
    func addHeader() {
        let cellHelper = LayoutCellHelper<String>(
            model: "",
            layoutCreator: ({ model in
                let title = NSAttributedString(
                    string: "Проверьте автомобиль\nперед покупкой",
                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)])
                
                let layout = StackLayout(
                    configNode: ({ node in
                        node.flexDirection = .row
                        node.flex = 1
                        node.padding = Edges(uniform: 8)
                    }),
                    children: [
                        TextLayout(
                            text: title,
                            configNode: ({ node in
                                node.margin = Edges(bottom: 8)
                            }),
                            configView: ({ view in
                                view.layer.borderColor = UIColor.red.cgColor
                                view.layer.borderWidth = 1
                            }))
                ])
                
                return layout
            }))
        
        addCellHelper(identifier: "header", cellHelper: cellHelper)
    }
 */
}



open class BaseTableModelBuilder {
    
    public enum SeparatorType {
        case small
        case customSmall(UIEdgeInsets)
        case medium
        case big
    }
    
    private let separatorColor = UIColor(rgb: 0xE5E5EA)
    private var items: [TableItem] = []
    private var idToNextIndex: [String: Int] = [:]
    
    // Base
    
    public init() {
    }
    
    public func addTableItem(_ tableItem: TableItem) {
        items.append(tableItem)
    }
    
    public func addCellHelper(identifier: String, cellHelper: CellHelper, actions: TableItemActions = TableItemActions(), idIncrementation: Bool = true) {
        if idIncrementation == false {
            var tableItem = TableItem(identifier: identifier, cellHelper: cellHelper)
            tableItem.actions = actions
            addTableItem(tableItem)
            return
        }
        
        let index: Int = idToNextIndex[identifier] ?? 0
        idToNextIndex[identifier] = index + 1
        let id = index > 0 ? "\(identifier)_\(index)" : identifier
        
        var tableItem = TableItem(identifier: id, cellHelper: cellHelper)
        tableItem.actions = actions
        addTableItem(tableItem)
    }
    
    public func build(identifier: String = "main", cleanupSeparators: Bool = true) -> [TableSection] {
        if cleanupSeparators {
            self.cleanupSeparators()
        }
        return [TableSection(identifier: identifier, items: items)]
    }
    
    // Base list items
    
    public func cleanupSeparators() {
        var cleanedItems: [TableItem] = []
        let smallSeparatorIdPrefix = "separator_\(SeparatorType.small)"
        
        var prevItem: TableItem?
        for item in items {
            if let prevItem = prevItem {
                if item.identifier.starts(with: "separator_") {
                    if prevItem.identifier.starts(with: smallSeparatorIdPrefix) {
                        cleanedItems.removeLast()
                    } else if prevItem.identifier.starts(with: "separator_") {
                        continue
                    }
                }
            }
            
            cleanedItems.append(item)
            prevItem = item
        }
        
        if let lastItem = cleanedItems.last {
            if lastItem.identifier.starts(with: "separator_") {
                cleanedItems.removeLast()
            }
        }
        
        self.items = cleanedItems
    }

    public func addSeparatorItem(_ type: SeparatorType, onDisplay: (() -> Void)? = nil) {
        let cellHelper: CellHelper
        let identifier: String

        let suffix: String
        if let prev = items.last {
            suffix = prev.identifier
        } else {
            suffix = ""
        }

        switch type {
        case .small:
            cellHelper = SmallSeparatorCellHelper(backgroundColor: separatorColor)
        case .customSmall(let insets):
            cellHelper = SmallSeparatorCellHelper(insets: insets)
        case .medium:
            cellHelper = BigSeparatorCellHelper(height: 8, color: separatorColor)
        case .big:
            cellHelper = BigSeparatorCellHelper(height: 16, color: separatorColor)
        }

        identifier = "separator_\(type)_\(suffix)"

        var actions: TableItemActions = TableItemActions()
        actions.onDisplay = { _ in
            onDisplay?()
        }

        addCellHelper(identifier: identifier, cellHelper: cellHelper, actions: actions)
    }

    public func addSpace(_ height: CGFloat, color: UIColor = .clear, customId: String? = nil) {
        let suffix: String
        if let custom = customId {
            suffix = custom
        } else if let prev = items.last {
            suffix = prev.identifier
        } else {
            suffix = ""
        }
        addCellHelper(identifier: "space_\(height)_\(suffix)",
            cellHelper: BigSeparatorCellHelper(height: height, color: color))
    }

    /*
    public func addLoadItem(_ identifier: String = "load") {
        let tableItem = TableItem(identifier: identifier, cellHelper: LoadCellHelper())
        addTableItem(tableItem)
    }

    public func addLoadMoreItem(backgroundColor: UIColor = .clear) {
        let tableItem = TableItem(identifier: "load_more", cellHelper: LoadCellHelper(backgroundColor: backgroundColor))
        addTableItem(tableItem)
    }

    public func addEmptyResultItem(title: String, backgroundColor: UIColor = .clear) {
        let tableItem = TableItem(identifier: "empty_result",
                                  cellHelper: EmptyResultCellHelper(model: title, backgroundColor: backgroundColor))
        addTableItem(tableItem)
    }
     */

    public func addTextButton(title: String, onTap: @escaping (() -> Void)) {
                
        let layoutCreator: (String) -> Layout = { model in
            let title = AttributedStringBuilder(text: model)
                .font(UIFont.systemFont(ofSize: 16, weight: .regular))
                .string()

            let layout = StackLayout(
                configNode: ({ node in
                    node.padding = Edges(left: 16, right: 16, bottom: 8, top: 8)
                }),
                children: [
                    TextLayout(text: title, configNode: ({ node in
                        node.margin = Edges(left: 0, right: 8, bottom: 0, top: 0)
                        node.minSize.height = 40
                        node.flex = 1
                    }))
                ]
            )

            return layout
        }

        let cellHelper = LayoutCellHelper(model: title,
                                          layoutCreator: layoutCreator)
        var actions = TableItemActions()
        actions.onTap = {
            onTap()
        }
        addCellHelper(identifier: "text_button", cellHelper: cellHelper, actions: actions)

    }
}

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

public enum EmptyCellHelperModel {
    case empty
}

public class SmallSeparatorLayout: WrappedViewLayout<SeparatorView> {
    public init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
                backgroundColor: UIColor? = nil) {
        
        super.init(
            configNode: ({ node in
                node.flexDirection = .column
                node.size.height = YGValue(1)
            }),
            configView: ({ (view) in
                view.isUserInteractionEnabled = false
                view.backgroundColor = backgroundColor
                view.leftInset = insets.left
                view.rightInset = insets.right
            }))
    }
}

public final class SmallSeparatorCellHelper: LayoutCellHelper<EmptyCellHelperModel> {

    public init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), backgroundColor: UIColor? = nil) {
        super.init(model: .empty) { (_) -> Layout in
            return SmallSeparatorLayout(insets: insets, backgroundColor: backgroundColor)
        }
    }
}

public final class BigSeparatorCellHelper: LayoutCellHelper<EmptyCellHelperModel> {

    public init(height: CGFloat, color: UIColor) {
        super.init(model: .empty) { (_) -> Layout in
            let layout = WrappedViewLayout<UIView>(
                configNode: ({ node in
                    node.size.height = YGValue(height)
                }),
                configView: ({ view in
                    view.backgroundColor = color
                })
            )
            return layout
        }
    }
}

public class SeparatorView: UIView {
    private let separator: UIView = UIView(frame: .zero)
    private let separatorHeight: CGFloat

    public var topInset: CGFloat
    public var leftInset: CGFloat
    public var rightInset: CGFloat

    public var separatorColor: UIColor? {
        set {
            separator.backgroundColor = newValue
        }
        get {
            return separator.backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        let scale = UIScreen.main.scale

        if abs(scale - 2.0) < CGFloat.ulpOfOne {
            separatorHeight = 0.5
        } else if abs(scale - 3.0) < CGFloat.ulpOfOne {
            separatorHeight = 0.33
        } else {
            separatorHeight = 1
        }

        topInset = 0
        leftInset = 0
        rightInset = 0
    
        separator.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)

        backgroundColor = .clear
        addSubview(separator)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        separator.frame = CGRect(x: leftInset, y: topInset, width: frame.width - leftInset - rightInset, height: separatorHeight)
    }
}
