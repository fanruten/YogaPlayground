import Foundation
import UIKit
import Yoga
import YogaSwift

public class WrappedViewLayout<View>: Layout where View: UIView {
    private let configNodeBlock: ((YogaNode) -> Void)?
    private let configViewBlock: ((View) -> Void)?
    private let createViewBlock: (() -> View)
    
    public let children: [Layout]
        
    public init(children: [Layout] = [],
                createViewBlock: @escaping (() -> View) = { View(frame: .zero) },
                configNode: ((YogaNode) -> Void)? = nil,
                configView: ((View) -> Void)? = nil) {
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
    
    open var viewRequired: Bool {
        return true
    }
}
