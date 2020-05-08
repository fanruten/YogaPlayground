import Foundation
import UIKit

public struct TableItemActions {
    public var onTap: (() -> Void)?
    public var onDelete: (() -> Void)?
    public var onTryEdit: (() -> Bool)?
    public var onDisplay: ((UIView) -> Void)?

    public init(onTap: (() -> Void)? = nil, onDelete: (() -> Void)? = nil, onTryEdit: (() -> Bool)? = nil, onDisplay: ((UIView) -> Void)? = nil) {
        self.onTap = onTap
        self.onDelete = onDelete
        self.onTryEdit = onTryEdit
        self.onDisplay = onDisplay
    }
}

public struct TableItem {
    public var identifier: String
    public var cellHelper: CellHelper
    public var actions: TableItemActions

    public init(identifier: String, cellHelper: CellHelper, actions: TableItemActions = TableItemActions()) {
        self.identifier = identifier
        self.cellHelper = cellHelper
        self.actions = actions
    }
}

extension TableItem: Diffable {
    public var diffIdentifier: AnyHashable {
        return identifier
    }
}

extension TableItem: Equatable {
    public static func ==(lhs: TableItem, rhs: TableItem) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.cellHelper.isEqual(to: rhs.cellHelper)
    }
}

func ==(lhs: [TableItem], rhs: [TableItem]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }

    var i1 = lhs.makeIterator()
    var i2 = rhs.makeIterator()
    var isEqual = true

    while let e1 = i1.next(), let e2 = i2.next(), isEqual {
        isEqual = e1 == e2
    }

    return isEqual
}

public struct TableSection {
    public var identifier: String
    public var items: [TableItem]

    public init(identifier: String = "", items: [TableItem] = []) {
        self.identifier = identifier
        self.items = items
    }
}

extension TableSection: Diffable {
    public var diffIdentifier: AnyHashable {
        return identifier
    }
}

extension TableSection: Equatable {
    public static func ==(lhs: TableSection, rhs: TableSection) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.items == rhs.items
    }
}

extension TableSection {
    mutating func insert(_ newElement: TableItem, at i: Int) {
        items.insert(newElement, at: i)
    }

    mutating func remove(at index: Int) -> TableItem {
        return items.remove(at: index)
    }

    public var isEmpty: Bool {
        return items.isEmpty
    }

    mutating func append(_ newElement: TableItem) {
        items.append(newElement)
    }

    mutating func append(contentsOf newElements: [TableItem]) {
        items.append(contentsOf: newElements)
    }

    var count: Int {
        return items.count
    }

    mutating func removeAll() {
        items.removeAll()
    }

    public subscript(index: Int) -> TableItem {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
}
