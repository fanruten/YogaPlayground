import Foundation

public struct AnimatedModelTransform {
    public let changes: [AnimatedTableItemChange]
    public let delayedChanges: [AnimatedTableItemChange]

    /// The model constructed from items of the old model and inserted or updated items from the new model.
    public let updatedModel: TableModel

    /// Indexex of insereted or updated items in `updatedModel`.
    public let newItemsIndexes: [IndexPath]
}

public class ModelTranformGenerator {

    private let model: TableModel

    public init(model: TableModel) {
        self.model = model
    }

    /// Generates `updatedModel` and preserves not changed items from `self.model`.
    public func calculateTransformTo(_ newModel: TableModel) -> AnimatedModelTransform {
        /// From Apple Docs:
        /// Deletes are processed before inserts in batch operations.
        /// This means the indexes for the deletions are processed relative to the indexes of the collection
        /// view’s state before the batch operation, and the indexes for the insertions are processed relative to
        /// the indexes of the state after all the deletions in the batch operation.

        let sectionDiff = List.diffing(oldArray: model.sections, newArray: newModel.sections)

        var sectionChanges = [SectionChange]()
        var updatedSections = model.sections

        sectionDiff.deletes.reversed().forEach { index in
            sectionChanges.append(.remove(RemoveSectionChange(index: index)))
            updatedSections.remove(at: index)
        }
        sectionDiff.inserts.forEach { index in
            sectionChanges.append(.insert(InsertSectionChange(index: index)))
            updatedSections.insert(newModel.sections[index], at: index)
        }
        sectionDiff.moves.forEach { moveIndex in
            sectionChanges.append(.move(MoveSectionChange(initialIndex: moveIndex.from, finalIndex: moveIndex.to)))
        }

        var newItemsIndexes = [IndexPath]()
        var rowChanges = [RowChange]()
        var delayedRowChanges = [RowChange]()

        for updatedSectionIndex in sectionDiff.updatesNew {
            let oldSection = updatedSections[updatedSectionIndex]
            let newSection = newModel.sections[updatedSectionIndex]
            var updatedSection = oldSection

            var skipRefreshIndexes = Set<Int>()

            let itemDiff = List.diffing(oldArray: oldSection.items, newArray: newSection.items)
            itemDiff.deletes.reversed().forEach { index in
                rowChanges.append(.remove(RemoveRowChange(index: index, sectionIndex: sectionDiff.oldIndexFor(identifier: updatedSection.identifier) ?? updatedSectionIndex)))
                updatedSection.items.remove(at: index)
            }
            itemDiff.inserts.forEach { index in
                rowChanges.append(.insert(InsertRowChange(index: index, sectionIndex: updatedSectionIndex)))
                updatedSection.insert(newSection[index], at: index)
                newItemsIndexes.append(IndexPath(row: index, section: updatedSectionIndex))
            }
            itemDiff.moves.sorted(by: { $0.from < $1.from }).forEach { moveIndex in
                skipRefreshIndexes.insert(moveIndex.from)

                guard moveIndex.from != moveIndex.to else {
                    delayedRowChanges.append(.refresh(RefreshRowChange(index: moveIndex.from, sectionIndex: updatedSectionIndex)))
                    newItemsIndexes.append(IndexPath(row: moveIndex.from, section: updatedSectionIndex))
                    return
                }

                rowChanges.append(.move(MoveRowChange(initialIndex: moveIndex.from,
                                                      finalIndex: moveIndex.to,
                                                      initialSectionIndex: updatedSectionIndex,
                                                      finalSectionIndex: updatedSectionIndex)))

                if let previousItemIndex = updatedSection.items.firstIndex(where: { $0.identifier == oldSection[moveIndex.from].identifier }) {
                    _ = updatedSection.remove(at: previousItemIndex)
                    updatedSection.insert(newSection[moveIndex.to], at: moveIndex.to)
                    delayedRowChanges.append(.refresh(RefreshRowChange(index: moveIndex.to, sectionIndex: updatedSectionIndex)))
                    newItemsIndexes.append(IndexPath(row: moveIndex.to, section: updatedSectionIndex))
                }
            }
            itemDiff.updatesOld.forEach { index in
                if skipRefreshIndexes.contains(index) == false {
                    rowChanges.append(.refresh(RefreshRowChange(index: index, sectionIndex: updatedSectionIndex)))
                }
            }
            itemDiff.updatesNew.forEach { index in
                if itemDiff.moves.contains(where: { $0.to == index }) {
                    return
                }
                let prevCellHelper = updatedSection[index].cellHelper
                updatedSection[index] = newSection[index]

                if prevCellHelper.updateBy(updatedSection[index].cellHelper) {
                    updatedSection[index].cellHelper = prevCellHelper
                }
                newItemsIndexes.append(IndexPath(row: index, section: updatedSectionIndex))
            }

            updatedSections[updatedSectionIndex] = updatedSection
        }

        sectionDiff.inserts.forEach { sectionIndex in
            let section = updatedSections[sectionIndex]
            for rowIndex in section.items.indices {
                newItemsIndexes.append(IndexPath(row: rowIndex, section: sectionIndex))
            }
        }

        var animations = [AnimatedTableItemChange]()
        animations.append(contentsOf: sectionChanges.map { change in
            let tableItemChange = TableItemChange.section(change)
            return AnimatedTableItemChange(tableItemChange: tableItemChange, animation: .fade)
        })
        animations.append(contentsOf: rowChanges.map { change in
            let tableItemChange = TableItemChange.row(change)
            return AnimatedTableItemChange(tableItemChange: tableItemChange, animation: .fade)
        })

        var delayedAnimations = [AnimatedTableItemChange]()
        delayedAnimations.append(contentsOf: delayedRowChanges.map { change in
            let tableItemChange = TableItemChange.row(change)
            return AnimatedTableItemChange(tableItemChange: tableItemChange, animation: .fade)
        })

        let updatedModel = TableModel(readyLoadMore: newModel.readyLoadMore,
                                      lastLoadFinishedWithError: newModel.lastLoadFinishedWithError,
                                      sections: updatedSections)

        let transform = AnimatedModelTransform(changes: animations,
                                               delayedChanges: delayedAnimations,
                                               updatedModel: updatedModel,
                                               newItemsIndexes: newItemsIndexes)
        return transform
    }
}
