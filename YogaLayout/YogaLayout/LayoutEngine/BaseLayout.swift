import Foundation
import UIKit
import Yoga
import YogaSwift

open class BaseLayout<Model, View>: Layout where View: UIView {
    private let configNodeBlock: ((YogaNode) -> Void)?
    private let configViewBlock: ((View) -> Void)?

    public let model: Model
    public let childs: [Layout]

    public init(model: Model,
                childs: [Layout] = [],
                configNode: ((YogaNode) -> Void)? = nil,
                configView: ((View) -> Void)? = nil) {
        self.model = model
        self.childs = childs
        self.configNodeBlock = configNode
        self.configViewBlock = configView
    }

    open func configNode(_ node: YogaNode) {
        configNodeBlock?(node)
    }

    open func configView(_ view: UIView) {
        guard let typedView = view as? View else {
            return
        }

        applyModel(to: typedView)
        configViewBlock?(typedView)
    }

    open func createView() -> UIView {
        let view = View(frame: .zero)
        view.backgroundColor = .clear
        return view
    }

    open var viewRequired: Bool {
        return true
    }

    // for subclasses

    open func applyModel(to view: View) {
    }
}
