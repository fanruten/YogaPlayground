import Foundation
import UIKit
import Yoga
import YogaSwift

open class CompoundLayout: Layout {
    private let layoutFactory: (() -> Layout)
    private lazy var layout: Layout = layoutFactory()

    public init(layout: @escaping (() -> Layout)) {
        self.layoutFactory = layout
    }

    public init(layout: Layout) {
        self.layoutFactory = { return layout }
    }
    
    public func configNode(_ node: YogaNode) {
        layout.configNode(node)
    }

    public func configView(_ view: UIView) {
        layout.configView(view)
    }

    public func createView() -> UIView {
        return layout.createView()
    }

    public var viewRequired: Bool {
        return layout.viewRequired
    }

    public var childs: [Layout] {
        return layout.childs
    }
}
