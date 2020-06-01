import Foundation
import UIKit

open class CompoundLayout<ModelType> {
    public let model: ModelType

    public init(model: ModelType) {
        self.model = model
    }

    public final func makeLayout() -> Layout {
        return makeLayoutFrom(model: model)
    }

    open func makeLayoutFrom(model: ModelType) -> Layout {
        fatalError()
    }
}

extension CompoundLayout {
    public final func createView(boundingSize: CGSize) -> UIView {
        let creator = BasicViewHierarchyCreator(rootComponent: makeLayout(), boundingSize: boundingSize)
        creator.calculateLayoutIfNeeded()
        return creator.createView()
    }
}
