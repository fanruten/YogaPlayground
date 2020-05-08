import Foundation
import UIKit
import Yoga
import YogaSwift

public class StackLayout: Layout {
    private let configNodeBlock: ((YogaNode) -> Void)?
    
    public let viewBuilder: ViewBuilder? = nil
    public let children: [Layout]
    
    public init(configNode: ((YogaNode) -> Void)? = nil,
                optChildren: [Layout?] = []) {
        self.children = optChildren.compactMap { $0 }
        self.configNodeBlock = configNode
    }
    
    public init(configNode: ((YogaNode) -> Void)? = nil,
                children: [Layout] = []) {
        self.children = children
        self.configNodeBlock = configNode
    }
        
    public func configNode(_ node: YogaNode) {
        configNodeBlock?(node)
    }    
}
