import Foundation
import UIKit

// MARK: - SectionChange

public struct InsertSectionChange {
    public var index: Int

    public init(index: Int) {
        self.index = index
    }
}

public struct RemoveSectionChange {
    public var index: Int

    public init(index: Int) {
        self.index = index
    }
}

public struct RefreshSectionChange {
    public var index: Int

    public init(index: Int) {
        self.index = index
    }
}

public struct MoveSectionChange {
    public var initialIndex: Int
    public var finalIndex: Int

    public init(initialIndex: Int, finalIndex: Int) {
        self.initialIndex = initialIndex
        self.finalIndex = finalIndex
    }
}

public enum SectionChange {
    case insert(InsertSectionChange)
    case remove(RemoveSectionChange)
    case refresh(RefreshSectionChange)
    case move(MoveSectionChange)
}

// MARK: - RowChange

public struct InsertRowChange {
    public var index: Int
    public var sectionIndex: Int

    public init(index: Int, sectionIndex: Int) {
        self.index = index
        self.sectionIndex = sectionIndex
    }
}

public struct RemoveRowChange {
    public var index: Int
    public var sectionIndex: Int

    public init(index: Int, sectionIndex: Int) {
        self.index = index
        self.sectionIndex = sectionIndex
    }
}

public struct RefreshRowChange {
    public var index: Int
    public var sectionIndex: Int

    public init(index: Int, sectionIndex: Int) {
        self.index = index
        self.sectionIndex = sectionIndex
    }
}

public struct MoveRowChange {
    public var initialIndex: Int
    public var finalIndex: Int

    public var initialSectionIndex: Int
    public var finalSectionIndex: Int

    public init(initialIndex: Int, finalIndex: Int, initialSectionIndex: Int, finalSectionIndex: Int) {
        self.initialIndex = initialIndex
        self.finalIndex = finalIndex
        self.initialSectionIndex = initialSectionIndex
        self.finalSectionIndex = finalSectionIndex
    }
}

public enum RowChange {
    case insert(InsertRowChange)
    case remove(RemoveRowChange)
    case refresh(RefreshRowChange)
    case move(MoveRowChange)
}

// MARK: - TableChange

public enum TableItemChange {
    case row(RowChange)
    case section(SectionChange)
}

public struct AnimatedTableItemChange {
    public var tableItemChange: TableItemChange
    public var animation: UITableView.RowAnimation

    public init(tableItemChange: TableItemChange, animation: UITableView.RowAnimation) {
        self.tableItemChange = tableItemChange
        self.animation = animation
    }
}

public enum AnimatedTableChange {
    case reload
    case update([AnimatedTableItemChange])
}
