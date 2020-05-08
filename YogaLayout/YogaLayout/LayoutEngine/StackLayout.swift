import Foundation
import UIKit
import Yoga
import YogaSwift

open class StackLayout: BaseLayout<Void, UIView> {
    public init(optChilds: [Layout?] = [], configNode: ((YogaNode) -> Void)? = nil) {
        super.init(model: (), childs: optChilds.compactMap { $0 }, configNode: configNode, configView: nil)
    }
    
    public init(childs: [Layout] = [], configNode: ((YogaNode) -> Void)? = nil) {
        super.init(model: (), childs: childs, configNode: configNode, configView: nil)
    }

    open override var viewRequired: Bool {
        return false
    }
}

open class StackWithBackgroundLayout: BaseLayout<Void, UIView> {
    public init(childs: [Layout] = [], configNode: ((YogaNode) -> Void)? = nil, configView: ((UIView) -> Void)? = nil) {
        super.init(model: (), childs: childs, configNode: configNode, configView: configView)
    }
}
