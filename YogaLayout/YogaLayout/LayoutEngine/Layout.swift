import Foundation
import UIKit
import Yoga
import YogaSwift

public protocol Layout {
    func configNode(_ node: YogaNode)
    func configView(_ view: UIView)

    func createView() -> UIView
    var viewRequired: Bool { get }

    var childs: [Layout] { get }
}

open class LayoutProvider<ModelType> {
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
