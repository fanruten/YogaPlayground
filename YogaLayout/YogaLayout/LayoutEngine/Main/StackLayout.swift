import Foundation
import UIKit
import Yoga
import YogaSwift

public class StackLayout: Layout {
    private let configNodeBlock: ((YogaNode) -> Void)?
    
    public let children: [Layout]
    
    public init(optChildren: [Layout?] = [],
                configNode: ((YogaNode) -> Void)? = nil) {
        self.children = optChildren.compactMap { $0 }
        self.configNodeBlock = configNode
    }
    
    public init(children: [Layout] = [],
                configNode: ((YogaNode) -> Void)? = nil) {
        self.children = children
        self.configNodeBlock = configNode
    }
        
    public func configNode(_ node: YogaNode) {
        configNodeBlock?(node)
    }
    
    public func configView(_ view: UIView) {
    }
    
    public func createView() -> UIView {
        return UIView(frame: .zero)
    }
    
    public var viewRequired: Bool {
        return false
    }
}
