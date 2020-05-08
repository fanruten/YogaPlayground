import Foundation
import UIKit
import Yoga
import YogaSwift

private class LayoutWithNode {
    var layout: Layout
    var node: YogaNode

    init(layout: Layout, node: YogaNode) {
        self.layout = layout
        self.node = node
    }
}

private class LayoutWithView {
    var layoutWithNode: LayoutWithNode
    var containerView: UIView
    var offset: CGPoint

    init(layoutWithNode: LayoutWithNode, containerView: UIView, offset: CGPoint) {
        self.layoutWithNode = layoutWithNode
        self.containerView = containerView
        self.offset = offset
    }
}

public class BasicViewHierarchyCreator {
    private let rootComponent: Layout
    private let boundingSize: CGSize

    public init(rootComponent: Layout, boundingSize: CGSize) {
        self.rootComponent = rootComponent
        self.boundingSize = boundingSize
    }

    public func createView() -> UIView {
        calculateLayoutIfNeeded()
        
        let rootView = UIView(frame: CGRect(origin: .zero, size: viewSize))
        rootView.backgroundColor = .clear
        var configBlocks: Array<() -> Void> = []
        
        layoutWithNodes.transformAndTraverseDepth { (current, parent) -> LayoutWithView? in
            guard !current.node.isHidden else {
                return nil
            }
            
            let frame: CGRect
            if let parentOffset = parent?.offset {
                var currentFrame = current.node.frame
                currentFrame.origin.x += parentOffset.x
                currentFrame.origin.y += parentOffset.y
                frame = currentFrame
            } else {
                frame = current.node.frame
            }

            guard current.layout.viewRequired else {
                return LayoutWithView(layoutWithNode: current, containerView: parent?.containerView ?? rootView, offset: frame.origin)
            }

            let view = current.layout.createView()
            view.frame = frame
            
            configBlocks.append({
                current.layout.configView(view)
            })

            if let containerView = parent?.containerView {
                containerView.addSubview(view)
            } else {
                rootView.addSubview(view)
            }

            return LayoutWithView(layoutWithNode: current, containerView: view, offset: .zero)
        }
        
        for config in configBlocks.reversed() {
            config()
        }

        return rootView
    }

    public lazy var viewSize: CGSize = {
        guard let node = layoutWithNodes.first()?.node else {
            return .zero
        }
        let size = node.calculateLayout(with: boundingSize)
        return size
    }()

    public func calculateLayoutIfNeeded() {
        _ = viewSize
    }

    // MARK: — Private

    /**
     Create yoga's nodes hierarhcy and bind it with Layout's hierarchy
     */

    private lazy var layoutWithNodes: Graph<LayoutWithNode> = {
        let layoutsGraph = Graph<Layout>(root: rootComponent) { (component) -> [Layout] in
            return component.childs
        }

        return layoutsGraph.transformAndTraverseBreadth { (current, parent) -> LayoutWithNode in
            let node = YogaNode()
            current.configNode(node)

            parent?.node.addSubnode(node)

            return LayoutWithNode(layout: current, node: node)
        }
    }()
}
