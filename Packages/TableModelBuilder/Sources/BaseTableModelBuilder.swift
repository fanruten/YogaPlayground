import TableController
import UIKit
import YogaLayout
import UIUtils
import YogaSwift

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
