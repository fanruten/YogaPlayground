import UIKit

public struct AutoDiffTableControllerCallbacks {
    public var didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)?
    public var willBeginDragging: (() -> Void)?

    public init(didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)? = nil, willBeginDragging: (() -> Void)? = nil) {
        self.didRequestLoadMore = didRequestLoadMore
        self.willBeginDragging = willBeginDragging
    }
}

public enum AutoDiffTableControllerError: Error {
    case indexOutOfBounds(Int)
}
