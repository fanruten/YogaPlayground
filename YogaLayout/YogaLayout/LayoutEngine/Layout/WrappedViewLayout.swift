import Foundation
import UIKit
import Yoga
import YogaSwift

open class WrappedViewLayout<View>: Layout, ViewBuilder where View: UIView {
    private let configNodeBlock: ((YogaNode) -> Void)?
    private let configViewBlock: ((View) -> Void)?
    private let createViewBlock: (() -> View)
    
    public var viewBuilder: ViewBuilder? {
        return self
    }
    public let children: [Layout]
        
    public init(createViewBlock: @escaping (() -> View) = { View(frame: .zero) },
                configNode: ((YogaNode) -> Void)? = nil,
                configView: ((View) -> Void)? = nil,
                children: [Layout] = []) {
        self.children = children
        self.createViewBlock = createViewBlock
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
        
        configViewBlock?(typedView)
    }
    
    open func createView() -> UIView {
        return createViewBlock()
    }
}
