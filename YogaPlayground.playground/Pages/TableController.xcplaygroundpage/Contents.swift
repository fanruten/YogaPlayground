import UIKit
import PlaygroundSupport
import YogaLayout
import Yoga
import YogaSwift
import TableController

extension String {
    static let nbsp = "\u{00a0}"
}

let autoDiffViewController = AutoDiffViewController(identifier: "Test", cellWidthMeasure: nil)
autoDiffViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 800)

let modelBuilder = BaseTableModelBuilder()
modelBuilder.addTextButton(title: "Kek", onTap: ({
    print("kek")
}))
modelBuilder.addTextButton(title: "Kek", onTap: ({
    print("kek")
}))
modelBuilder.addTextButton(title: "Kek", onTap: ({
    print("kek")
}))

autoDiffViewController.updateTableModel(with: TableModel(readyLoadMore: false, lastLoadFinishedWithError: false, sections: modelBuilder.build()))
autoDiffViewController.view.backgroundColor = .red

PlaygroundPage.current.liveView = autoDiffViewController.view
PlaygroundPage.current.needsIndefiniteExecution = true


//final class SimpleTableModelBuilder: BaseTableModelBuilder {
    
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
//}



open class BaseTableModelBuilder {
    
    public enum SeparatorType {
        case small
        case customSmall(UIEdgeInsets)
        case medium
        case big
    }
    
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

    /*
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
            cellHelper = SmallSeparatorCellHelper()
        case .customSmall(let insets):
            cellHelper = SmallSeparatorCellHelper(insets: insets)
        case .medium:
            cellHelper = BigSeparatorCellHelper(height: 8, color: Appearance.General.largeSeparatorColor)
        case .big:
            cellHelper = BigSeparatorCellHelper(height: 16, color: Appearance.General.largeSeparatorColor)
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
            let title = AttributedStringBuilder(text: "model")
                .font(UIFont.systemFont(ofSize: 16, weight: .regular))
                .string()

            let layout = WrappedViewLayout<UIView>(
                configNode: ({ node in
                    node.padding = Edges(left: 16, right: 16, bottom: 8, top: 8)
                }),
                configView: ({ view in
                    view.backgroundColor = .white
                }),
                children: [
                    TextLayout(
                        text: title,
                               configNode: ({ node in
                                node.margin = Edges(left: 0, right: 8, bottom: 0, top: 0)
                                node.minSize.height = 40
                                node.flex = 1
                               }),
                               configView: ({ view in
                                view.backgroundColor = .green
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
    
    public var setupInitialCollectionAttributesForAppearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)?
    public var setupFinalCollectionAttributesForDisappearing: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)?
    public var setupDefaultCollectionAttributes: ((_ attributes: UICollectionViewLayoutAttributes) -> Void)?
}


//
//  AttributedString.swift
//  Auto.ru
//
//  Created by Ruslan V. Gumennyy on 06/09/2017.
//  Copyright © 2017 Auto.ru. All rights reserved.
//

import Foundation
import UIKit

public func + (x: NSAttributedString, y: NSAttributedString) -> NSAttributedString {
    return x.concatenate(with: y)
}

public func += (x: inout NSAttributedString, y: NSAttributedString) {
    x = x + y
}

extension NSAttributedString {
    public func concatenate(with attributedString: NSAttributedString) -> NSAttributedString {
        let x = NSMutableAttributedString()

        x.append(self)
        x.append(attributedString)

        return x
    }
}

extension String {
    public func attributed() -> AttributedStringBuilder {
        return AttributedStringBuilder(text: self)
    }
}

public final class AttributedStringBuilder {
    private let text: String

    public init(text: String) {
        self.text = text
    }

    // MARK: -

    public private(set) var attributes = [NSAttributedString.Key: Any]()

    private var paragraphStyle: NSMutableParagraphStyle {
        if let style = attributes[.paragraphStyle] as? NSMutableParagraphStyle {
            return style
        }

        let style = NSMutableParagraphStyle()

        attributes[.paragraphStyle] = style

        return style
    }

    // MARK: -

    public func string() -> NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: attributes
        )
    }

    public func mutableString() -> NSMutableAttributedString {
        return NSMutableAttributedString(
            string: text,
            attributes: attributes
        )
    }

    // MARK: -

    public func alignment(_ value: NSTextAlignment) -> Self {
        paragraphStyle.alignment = value

        return self
    }

    public func allowsDefaultTighteningForTruncation(_ value: Bool) -> Self {
        paragraphStyle.allowsDefaultTighteningForTruncation = value

        return self
    }

    public func backgroundColor(_ value: UIColor) -> Self {
        attributes[.backgroundColor] = value

        return self
    }

    public func baseWritingDirection(_ value: NSWritingDirection) -> Self {
        paragraphStyle.baseWritingDirection = value

        return self
    }

    public func baselineOffset(_ value: Float) -> Self {
        attributes[.baselineOffset] = NSNumber(value: value)

        return self
    }

    public func defaultTabInterval(_ value: CGFloat) -> Self {
        paragraphStyle.defaultTabInterval = value

        return self
    }

    public func expansion(_ value: Float) -> Self {
        attributes[.expansion] = NSNumber(value: value)

        return self
    }

    public func firstLineHeadIndent(_ value: CGFloat) -> Self {
        paragraphStyle.firstLineHeadIndent = value

        return self
    }

    public func font(_ value: UIFont) -> Self {
        attributes[.font] = value

        return self
    }

    public func foregroundColor(_ value: UIColor) -> Self {
        attributes[.foregroundColor] = value

        return self
    }

    public func headIndent(_ value: CGFloat) -> Self {
        paragraphStyle.headIndent = value

        return self
    }

    public func hyphenationFactor(_ value: Float) -> Self {
        paragraphStyle.hyphenationFactor = value

        return self
    }

    public func kern(_ value: Float) -> Self {
        attributes[.kern] = NSNumber(value: value)

        return self
    }

    public func ligature(_ value: Int) -> Self {
        attributes[.ligature] = NSNumber(value: value)

        return self
    }

    public func lineBreakMode(_ value: NSLineBreakMode) -> Self {
        paragraphStyle.lineBreakMode = value

        return self
    }

    public func lineHeightMultiple(_ value: CGFloat) -> Self {
        paragraphStyle.lineHeightMultiple = value

        return self
    }

    public func lineSpacing(_ value: CGFloat) -> Self {
        paragraphStyle.lineSpacing = value

        return self
    }

    public func maximumLineHeight(_ value: CGFloat) -> Self {
        paragraphStyle.maximumLineHeight = value

        return self
    }

    public func minimumLineHeight(_ value: CGFloat) -> Self {
        paragraphStyle.minimumLineHeight = value

        return self
    }

    public func obliqueness(_ value: Float) -> Self {
        attributes[.obliqueness] = NSNumber(value: value)

        return self
    }

    public func paragraphSpacing(_ value: CGFloat) -> Self {
        paragraphStyle.paragraphSpacing = value

        return self
    }

    public func paragraphSpacingBefore(_ value: CGFloat) -> Self {
        paragraphStyle.paragraphSpacingBefore = value

        return self
    }

    public func shadow(offsetX: CGFloat,
                       offsetY: CGFloat,
                       blurRadius: CGFloat,
                       color: UIColor?) -> Self {
        let value = NSShadow()
        value.shadowOffset = CGSize(width: offsetX, height: offsetY)
        value.shadowBlurRadius = blurRadius
        value.shadowColor = color

        attributes[.shadow] = value

        return self
    }

    public func strikethroughColor(_ value: UIColor) -> Self {
        attributes[.strikethroughColor] = value

        return self
    }

    public func strikethroughStyle(_ value: Int) -> Self {
        attributes[.strikethroughStyle] = NSNumber(value: value)

        return self
    }

    public func strokeColor(_ value: UIColor) -> Self {
        attributes[.strokeColor] = value

        return self
    }

    public func strokeWidth(_ value: Float) -> Self {
        attributes[.strokeWidth] = NSNumber(value: value)

        return self
    }

    public func tailIndent(_ value: CGFloat) -> Self {
        paragraphStyle.tailIndent = value

        return self
    }

    public func underlineColor(_ value: UIColor) -> Self {
        attributes[.underlineColor] = value

        return self
    }

    public func underlineStyle(_ value: NSUnderlineStyle) -> Self {
        attributes[.underlineStyle] = NSNumber(value: value.rawValue)

        return self
    }
}

extension AttributedStringBuilder {
    public func lineHeight(_ value: CGFloat) -> Self {
        return minimumLineHeight(value).maximumLineHeight(value)
    }
}
