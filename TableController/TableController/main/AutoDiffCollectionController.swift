import UIKit

public struct AutoDiffCollectionControllerCallbacks {
    public var didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)?
    public var willBeginDragging: (() -> Void)?
    
    public init(didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)? = nil, willBeginDragging: (() -> Void)? = nil) {
        self.didRequestLoadMore = didRequestLoadMore
        self.willBeginDragging = willBeginDragging
    }
}

public enum AutoDiffCollectionControllerError: Error {
    case indexOutOfBounds(Int)
}

open class AutoDiffCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private enum Consts {
        static let loadMoreItemsLeftCount = 4
        static let overlayCellIdentifier = "overlayCellIdentifier"
    }
    
    private let operationQueue = OperationQueue()
    private (set) public var tableModel = TableModel()

    // MARK: - Public

    public var callbacks = AutoDiffCollectionControllerCallbacks(didRequestLoadMore: nil)

    public weak var collectionView: UICollectionView? = nil {
        didSet {
            guard let collectionView = collectionView else {
                return
            }

            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(OverlayHighlightedCollectionCell.self, forCellWithReuseIdentifier: Consts.overlayCellIdentifier)
            setupCollectionView(collectionView: collectionView)
        }
    }

    public var minimumCellHeight: CGFloat?

    deinit {
        if let cv = collectionView {
            if Thread.isMainThread {
                cv.delegate = nil
                cv.dataSource = nil
            } else {
                DispatchQueue.main.async {
                    cv.delegate = nil
                    cv.dataSource = nil
                }
            }
        }
    }

    public func refresh() {
        updateTableModel(with: tableModel)
    }

    public func updateTableModel(with newModel: TableModel,
                                 completion: (() -> Void)? = nil,
                                 sync: Bool = false,
                                 animated: Bool = true) {
        if sync {
            updateTableModelSync(with: { return newModel }, completion: completion, animated: animated)
        } else {
            updateTableModel(with: { return newModel }, completion: completion, animated: animated)
        }
    }

    private let semaphore = DispatchSemaphore(value: 1)

    private func updateTableModelSync(with newModelCreator: @escaping (() -> TableModel),
                                      completion: (() -> Void)?,
                                      animated: Bool) {
        operationQueue.cancelAllOperations()
        guard collectionView != nil else {
            return
        }
        let cellWidth = self.cellWidth()

        let newModel = newModelCreator()
        let transform = ModelTranformGenerator(model: self.tableModel).calculateTransformTo(newModel)

        // Calculates layout for new or updated items.
        for indexPath in transform.newItemsIndexes {
            let tableItem = transform.updatedModel.sections[indexPath.section][indexPath.row]
            tableItem.cellHelper.precalculateLayout(indexPath: indexPath, width: cellWidth)
        }

        let applyCompletion: (() -> Void) = {
            self.semaphore.signal()
            completion?()
            self.didUpdateChanges()
            self.didUpdateModel()
        }

        guard !transform.changes.isEmpty else {
            applyCompletion()

            return
        }

        let oldModelEmpty = self.tableModel.sections.flatMap({ $0.items }).isEmpty
        let newModelEmpty = transform.updatedModel.sections.flatMap({ $0.items }).isEmpty

        self.tableModel = transform.updatedModel

        if newModelEmpty || oldModelEmpty {
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.layoutIfNeeded()
            applyCompletion()
            return
        }

        if let collectionView = self.collectionView {
            if !transform.delayedChanges.isEmpty {
                self.applyChanges(transform.changes, for: collectionView, completion: nil, animated: animated)
                self.applyChanges(transform.delayedChanges, for: collectionView, completion: applyCompletion, animated: animated)
            } else {
                self.applyChanges(transform.changes, for: collectionView, completion: applyCompletion, animated: animated)
            }
        } else {
            applyCompletion()
        }
    }

    public func updateTableModel(with newModelCreator: @escaping (() -> TableModel),
                                 completion: (() -> Void)? = nil,
                                 animated: Bool) {
        operationQueue.cancelAllOperations()

        guard let collectionView = self.collectionView else {
            return
        }

        let cellWidth = self.cellWidth()

        /*
        do {
            let contentInset = collectionView.contentInset.top

            if collectionView.contentOffset.y + contentInset < 0 && !operationQueue.isSuspended {
                operationQueue.isSuspended = true

                collectionView.rx.contentOffset
                    .filter { offset -> Bool in
                        offset.y + contentInset >= 0
                    }
                    .take(1)
                    .subscribe(onNext: { [weak self] offset in
                        self?.operationQueue.isSuspended = false
                    })
                    .disposed(by: disposeBag)
            }
        }
 */

        operationQueue.addOperation({ () -> Void in
            self.semaphore.wait()
            
            let newModel = newModelCreator()
            let transform = ModelTranformGenerator(model: self.tableModel).calculateTransformTo(newModel)

            // Calculates layout for new or updated items.
            for indexPath in transform.newItemsIndexes {
                let tableItem = transform.updatedModel.sections[indexPath.section][indexPath.row]
                tableItem.cellHelper.precalculateLayout(indexPath: indexPath, width: cellWidth)
            }

            let applyCompletion: (() -> Void) = {
                self.semaphore.signal()
                completion?()
                self.didUpdateChanges()
                self.didUpdateModel()
            }

            DispatchQueue.main.sync(execute: { () -> Void in
                guard !transform.changes.isEmpty else {
                    applyCompletion()

                    return
                }
                
                let oldModelEmpty = self.tableModel.sections.flatMap({ $0.items }).isEmpty
                let newModelEmpty = transform.updatedModel.sections.flatMap({ $0.items }).isEmpty

                self.tableModel = transform.updatedModel

                if newModelEmpty || oldModelEmpty {
                    self.collectionView?.reloadData()
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    self.collectionView?.layoutIfNeeded()
                    applyCompletion()
                    return
                }

                if let collectionView = self.collectionView {
                    if !transform.delayedChanges.isEmpty {
                        self.applyChanges(transform.changes, for: collectionView, completion: nil, animated: animated)
                        self.applyChanges(transform.delayedChanges, for: collectionView, completion: applyCompletion, animated: animated)
                    } else {
                        self.applyChanges(transform.changes, for: collectionView, completion: applyCompletion, animated: animated)
                    }
                } else {
                    applyCompletion()
                }
            })
        })
    }

    public func cellHelpers<T: CellHelper>(type: T.Type, section: Int) -> [T] {
        var cellHelpers: [T] = []
        if let tableItems = tableModel.sections[safe: section]?.items {
            for item in tableItems {
                if let cellHelper = item.cellHelper as? T {
                    cellHelpers.append(cellHelper)
                }
            }
        }
        return cellHelpers
    }

    open func setupCollectionView(collectionView: UICollectionView) {
    }

    open func didUpdateChanges() {
    }

    // MARK: — Consturction

    public typealias CellWidthMeasure = ((UIView) -> CGFloat)
    private let cellWidthMeasure: CellWidthMeasure?
    private var identifier: String

    public init(identifier: String, tableModel: TableModel = TableModel(), cellWidthMeasure: CellWidthMeasure? = nil) {
        self.operationQueue.maxConcurrentOperationCount = 1
        self.identifier = identifier
        self.tableModel = tableModel
        self.cellWidthMeasure = cellWidthMeasure

        super.init()
    }

    public var maxWidth: CGFloat?

    private func cellWidth() -> CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }

        let width: CGFloat
        if let cellWidthMeasure = cellWidthMeasure {
            width = cellWidthMeasure(collectionView)
        } else {
            width = collectionView.frame.width
        }

        if let maxWidth = maxWidth, width > maxWidth {
            return maxWidth
        }

        return width
    }

    // MARK: - CellHelper wrappers

    private func tableItemForIndexPath(_ indexPath: IndexPath) throws -> TableItem {
        let section = tableModel.sections[indexPath.section]
        if indexPath.row > section.count - 1 {
            throw AutoDiffTableControllerError.indexOutOfBounds(indexPath.row)
        }
        return section[indexPath.row]
    }

    private func cellHelperForIndexPath(_ indexPath: IndexPath) throws -> CellHelper {
        return try tableItemForIndexPath(indexPath).cellHelper
    }

    private func cellForIndexPath(_ indexPath: IndexPath, collectionView: UICollectionView) throws -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: Consts.overlayCellIdentifier, for: indexPath)
    }

    private func configureCellForIndexPath(cell: UICollectionViewCell, indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            guard let cellHelper = try? cellHelperForIndexPath(indexPath) else {
                return
            }
            let tableItem = try? tableItemForIndexPath(indexPath)

            let view = cellHelper.createCellView(width: cell.bounds.width)
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }

            cell.accessibilityIdentifier = tableItem?.identifier

            cell.contentView.addSubview(view)
            cell.contentView.backgroundColor = .clear
            view.frame = cell.bounds
        }
    }

    private func indexPathForItemWithIdentifier(_ identifier: String) -> IndexPath? {
        var sectionResult: Int?
        var itemResult: Int?

        for (sectionIndex, section) in tableModel.sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() where item.identifier == identifier {
                sectionResult = sectionIndex
                itemResult = itemIndex
            }
        }

        guard let sectionIndex = sectionResult,
            let itemIndex = itemResult else {
                return nil
        }

        return IndexPath(item: itemIndex, section: sectionIndex)
    }
    
    public func windowFrameForItem(indexPath: IndexPath) -> CGRect? {
        let attributes = collectionView?.layoutAttributesForItem(at: indexPath)
        
        guard let frame = attributes?.frame,
            let collectionFrame = collectionView?.convert(frame, to: collectionView?.superview),
            let windowFrame = collectionView?.superview?.convert(collectionFrame, to: nil) else {
                return nil
        }
        return windowFrame
    }

    public func windowFrameForItem(identifier: String) -> CGRect? {
        guard let indexPath = indexPathForItemWithIdentifier(identifier) else {
            return nil
        }

        return windowFrameForItem(indexPath: indexPath)
    }
    
    public func imageForVisibleItem(indexPath: IndexPath) -> UIImage {
        guard let collectionView = collectionView,
            collectionView.indexPathsForVisibleItems.contains(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) else {
                return UIImage()
        }
        
        let renderer = UIGraphicsImageRenderer(size: cell.bounds.size)
        let capturedImage = renderer.image { _ in
            cell.drawHierarchy(in: cell.bounds, afterScreenUpdates: true)
        }
        return capturedImage
    }

    public func imageForVisibleItem(identifier: String) -> UIImage {
        guard let indexPath = indexPathForItemWithIdentifier(identifier) else {
            return UIImage()
        }
        
        return imageForVisibleItem(indexPath: indexPath)
    }

    // MARK: — Utils

    private func applyChanges(_ changes: [AnimatedTableItemChange],
                              for collectionView: UICollectionView,
                              completion: (() -> Void)?,
                              animated: Bool) {
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }

        collectionView.performBatchUpdates(({
            for animatedChange in changes {
                switch animatedChange.tableItemChange {
                case let .section(sectionChange):
                    switch sectionChange {
                    case let .insert(insertSectionChange):
                        collectionView.insertSections(IndexSet(integer: insertSectionChange.index))

                    case let .remove(removeSectionChange):
                        collectionView.deleteSections(IndexSet(integer: removeSectionChange.index))

                    case let .refresh(refreshSectionChange):
                        collectionView.reloadSections(IndexSet(integer: refreshSectionChange.index))

                    case let .move(moveSectionChange):
                        collectionView.moveSection(moveSectionChange.initialIndex, toSection: moveSectionChange.finalIndex)
                    }

                case let .row(rowChange):
                    switch rowChange {
                    case let .insert(insertRowChange):
                        let indexPath = IndexPath(row: Int(insertRowChange.index), section: insertRowChange.sectionIndex)
                        collectionView.insertItems(at: [indexPath])

                    case let .remove(removeRowChange):
                        let indexPath = IndexPath(row: Int(removeRowChange.index), section: removeRowChange.sectionIndex)
                        collectionView.deleteItems(at: [indexPath])

                    case let .refresh(refreshRowChange):
                        let indexPath = IndexPath(row: Int(refreshRowChange.index),
                                                  section: refreshRowChange.sectionIndex)
                        collectionView.reloadItems(at: [indexPath])
                        
                    case let .move(moveRowChange):
                        let fromIndexPath = IndexPath(row: Int(moveRowChange.initialIndex),
                                                      section: moveRowChange.initialSectionIndex)
                        let toIndexPath = IndexPath(row: Int(moveRowChange.finalIndex),
                                                    section: moveRowChange.finalSectionIndex)
                        collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
                    }
                }
            }

        }), completion: ({ _ in
            if !animated {
                CATransaction.commit()
            }
            completion?()
        }))
    }

    public func scrollToItemWithIdentifier(_ itemId: String, scrollPosition: UICollectionView.ScrollPosition = .top, animated: Bool = true) {
        let scrollQueue = DispatchQueue(label: "scrollQueue", attributes: .concurrent)

        scrollQueue.async { [weak self] in
            self?.operationQueue.waitUntilAllOperationsAreFinished()
            _ = self?.tableModel.sections.enumerated().contains(where: { sectionIndex, section in
                return section.items.enumerated().contains(where: { itemIndex, item in
                    if item.identifier == itemId {
                        DispatchQueue.main.async {
                            if animated {
                                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                                    self?.collectionView?.scrollToItem(at: IndexPath(item: itemIndex, section: sectionIndex), at: scrollPosition, animated: false)
                                })
                            } else {
                                self?.collectionView?.scrollToItem(at: IndexPath(item: itemIndex, section: sectionIndex), at: scrollPosition, animated: false)
                            }
                        }
                        return true
                    } else {
                        return false
                    }
                })
            })
        }
    }

    public subscript(indexPath: IndexPath) -> TableItem? {
        return tableModel.sections[safe: indexPath.section]?.items[safe: indexPath.row]
    }

    // MARK: - UICollectionViewDelegate

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        callbacks.willBeginDragging?()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollVelocity = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        let isDownScrollDirection = scrollVelocity.y < 0

        guard isDownScrollDirection else {
            return
        }

        guard
            let visibleCellsIndexPaths = collectionView?.indexPathsForVisibleItems,
            let firstVisibleIndexPath = visibleCellsIndexPaths.first else {
                return
        }

        let maxVisibleIndexPath = visibleCellsIndexPaths.reduce(firstVisibleIndexPath) { (result, path) in
            switch path.compare(result) {
            case .orderedDescending:
                return path
            case .orderedSame, .orderedAscending:
                return result
            }
        }

        var itemsToLast = 0
        for sectionIndex in (maxVisibleIndexPath.section..<tableModel.sections.count).reversed() {
            let sectionItemsCount: Int

            let section = tableModel.sections[sectionIndex]
            guard maxVisibleIndexPath.row < section.items.count else {
                continue
            }

            if sectionIndex == maxVisibleIndexPath.section, let items = section.items[safe: maxVisibleIndexPath.row..<section.items.count] {
                sectionItemsCount = items.count
            } else {
                sectionItemsCount = section.items.count
            }
            itemsToLast += sectionItemsCount
        }

        if tableModel.readyLoadMore, itemsToLast >= 0 && itemsToLast < Consts.loadMoreItemsLeftCount {
            let lastCellVisible = (itemsToLast <= 1)
            didRequestLoadMoreSubject(lastCellVisible)
        }
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let tableItem = try? tableItemForIndexPath(indexPath), tableItem.actions.onTap != nil else {
            return false
        }

        return true
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let tableItem = try? tableItemForIndexPath(indexPath), tableItem.actions.onTap != nil else {
            return false
        }

        return true
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let tableItem = try? tableItemForIndexPath(indexPath) {
            tableItem.actions.onDisplay?(cell)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let tableItem = try? tableItemForIndexPath(indexPath) else {
            return
        }

        tableItem.actions.onTap?()
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableModel.sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionData = tableModel.sections[section]
        return sectionData.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = try! cellForIndexPath(indexPath, collectionView: collectionView)
        configureCellForIndexPath(cell: cell, indexPath: indexPath)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellHelper = try? cellHelperForIndexPath(indexPath) else {
            return CGSize.zero
        }

        if cellHelper.precalculatedLayoutSize == nil || abs(
            cellHelper.precalculatedLayoutSize!.width - cellWidth()) > 0.1 {
            cellHelper.precalculateLayout(indexPath: indexPath, width: cellWidth())
        }

        guard var precalculatedLayoutSize = cellHelper.precalculatedLayoutSize else {
            return CGSize.zero
        }

        if let minimumCellHeight = self.minimumCellHeight {
            precalculatedLayoutSize.height = max(precalculatedLayoutSize.height, minimumCellHeight)
        }

        return precalculatedLayoutSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        guard flowLayout.scrollDirection == .vertical else {
            return flowLayout.sectionInset
        }

        let edgeInsets = (collectionView.frame.size.width - cellWidth()) / 2
        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
    }
    
    private func didRequestLoadMoreSubject(_ lastCellVisible: Bool) {
    }
    
    private func didUpdateModel() {
    }
}
