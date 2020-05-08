import Foundation
import UIKit
import Yoga
import YogaSwift

public class WrappedViewLayout<View>: Layout where View: UIView {
    private let configNodeBlock: ((YogaNode) -> Void)?
    private let configViewBlock: ((View) -> Void)?
    private let createViewBlock: (() -> View)
    
    public let childs: [Layout]
    
    public init(childs: [Layout] = [],
                createViewBlock: @escaping (() -> View),
                configNode: ((YogaNode) -> Void)? = nil,
                configView: ((View) -> Void)? = nil) {
        self.childs = childs
        self.createViewBlock = createViewBlock
        self.configNodeBlock = configNode
        self.configViewBlock = configView
    }
    
    public convenience init(childs: [Layout] = [],
                            configNode: ((YogaNode) -> Void)? = nil,
                            configView: ((View) -> Void)? = nil) {
        self.init(childs: childs,
                  createViewBlock: ({
                    return View(frame: .zero)
                  }),
                  configNode: configNode,
                  configView: configView)
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
