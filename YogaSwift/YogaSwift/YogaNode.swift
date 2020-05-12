import Foundation
import Yoga

public class YogaNode {
    /// Specifies how flex-items are placed in the flex-container (defining the main-axis).
    /// - Note: Applies to flex-container.
    public var flexDirection: YGFlexDirection = .row

    /// Specifies whether flex items are forced into a single line
    /// or can be wrapped onto multiple lines.
    /// - Note: Applies to flex-container.
    public var flexWrap: YGWrap = .noWrap

    /// Distributes space between and around flex-items along the main-axis.
    /// - Note: Applies to flex-container.
    public var justifyContent: YGJustify = .flexStart

    /// Distributes space between and around flex-items along the cross-axis.
    /// This works like `justifyContent` but in the perpendicular direction.
    /// - Note: Applies to flex-container.
    public var alignItems: YGAlign = .stretch

    /// Aligns a flex-container's lines when there is extra space on the cross-axis.
    /// - Warning: This property has no effect on single line.
    /// - Note: Applies to multi-line flex-container (no `FlexWrap.nowrap`).
    public var alignContent: YGAlign = .flexStart

    /// Aligns self (flex-item) by overriding it's parent's (flex-container) `alignItems`.
    /// - Note: Applies to flex-item.
    public var alignSelf: YGAlign = .auto

    /// Shorthand property specifying the ability of a flex-item
    /// to alter its dimensions to fill available space.
    /// - Note: Applies to flex-item.
    public var flex: CGFloat = .nan

    /// Grow factor of a flex-item.
    /// - Note: Applies to flex-item.
    public var flexGrow: CGFloat = .nan

    /// Shrink factor of a flex-item.
    /// - Note: Applies to flex-item.
    public var flexShrink: CGFloat = .nan

    /// Initial main size of a flex item.
    /// - Note: Applies to flex-item.
    public var flexBasis: YGValue = YGValue.nan

    public var aspectRatio: CGFloat = .nan

    public var direction: YGDirection = .inherit
    public var overflow: YGOverflow = .visible
    public var positionType: YGPositionType = .relative

    /// CSS's (top, right, bottom, left) that works with `positionType = .absolute`.
    public var position: Edges = .undefined

    /// By applying Margin to an item you specify the offset a certain edge of the item should have from it’s closest sibling or parent.
    public var margin: Edges = .undefined

    /// Padding you specify the offset children should have from a certain edge on the parent.
    public var padding: Edges = .undefined

    /// Border behaves nearly identically to Padding and is only separate from Padding to make it easier to implement border effect such as color.
    public var border: Edges = .undefined

    public var isHidden: Bool = false

    public var tag: Int?

    public var size: YogaSize = YogaSize.nan
    public var minSize: YogaSize = YogaSize.nan
    public var maxSize: YogaSize = YogaSize.nan
    
    public var isDirty: Bool {
        return YGNodeIsDirty(_node)
    }

    public var numberOfChildren: UInt32 {
        return YGNodeGetChildCount(_node)
    }

    public typealias ContentSizeMeasureFunc = (Float, YGMeasureMode, Float, YGMeasureMode) -> CGSize

    public var contentSize: ContentSizeMeasureFunc?

    // MARK: — Private

    private let _node: YGNodeRef
    private var _subnodes: [YogaNode]

    private static var globalConfig: YGConfigRef = {
        let globalConfig = YGConfigNew()
        YGConfigSetPointScaleFactor(globalConfig, Float(UIScreen.main.scale))
        return globalConfig!
    }()

    public init() {
        _node = YGNodeNewWithConfig(YogaNode.globalConfig)
        _subnodes = []

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        YGNodeSetContext(_node, context)

        YGNodeSetMeasureFunc(_node, { node, width, widthMode, height, heightMode in
            if let context = YGNodeGetContext(node) {
                let yogaNode = Unmanaged<YogaNode>.fromOpaque(context).takeUnretainedValue()

                if let size = yogaNode.contentSize?(width, widthMode, height, heightMode) {
                    return YGSize(width: Float(size.width), height: Float(size.height))
                }
            }

            return YGSize(width: 0, height: 0)
        })
    }

    deinit {
        YGNodeFree(_node)
    }

    @discardableResult public func calculateLayout(with size: CGSize) -> CGSize {
        var nodes = [YogaNode]()
        var topNode: YogaNode? = self
        while true {
            guard let node = topNode else {
                break
            }

            node.updateStyle()

            for subnode in node._subnodes {
                subnode.updateStyle()
            }

            nodes.append(contentsOf: node._subnodes)
            topNode = nodes.popLast()
        }

        YGNodeCalculateLayout(
                _node,
                Float(size.width),
                Float(size.height),
                YGNodeStyleGetDirection(_node))

        return CGSize(width: CGFloat(YGNodeLayoutGetWidth(_node)), height: CGFloat(YGNodeLayoutGetHeight(_node)))
    }

    public func configureNode(_ configure: ((YogaNode) -> Void)) {
        configure(self)
    }

    public func addSubnode(_ subnode: YogaNode) {
        _subnodes.append(subnode)

        while YGNodeGetChildCount(_node) > 0 {
            YGNodeRemoveChild(_node, YGNodeGetChild(_node, YGNodeGetChildCount(_node) - 1))
        }

        YGNodeSetMeasureFunc(_node, nil)

        for (index, node) in _subnodes.enumerated() {
            YGNodeInsertChild(_node, node._node, UInt32(index))
        }
    }

    public var frame: CGRect {
        let x = YGNodeLayoutGetLeft(_node)
        let y = YGNodeLayoutGetTop(_node)
        let width = YGNodeLayoutGetWidth(_node)
        let height = YGNodeLayoutGetHeight(_node)
        let frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
        return frame
    }

    public func printDescription() {
        let strTag: String
        if let tag = tag {
            strTag = String(tag)
        } else {
            strTag = "?"
        }

        print("<\(self)> tag=\"\(strTag)\" frame=\"\(frame)\"")
    }

    public func printNodes() {
        var nodes = [YogaNode]()
        var topNode: YogaNode? = self
        while true {
            guard let node = topNode else {
                break
            }

            node.printDescription()

            for subnode in node._subnodes {
                subnode.printDescription()
            }

            nodes.append(contentsOf: node._subnodes)
            topNode = nodes.popLast()
        }
    }

    public func apply(to view: UIView) {
        var tagToView = [Int: UIView]()

        var views = [UIView]()
        var topView: UIView? = view
        while true {
            guard let view = topView else {
                break
            }

            tagToView[view.tag] = view

            for subView in view.subviews {
                tagToView[subView.tag] = subView
            }

            views.append(contentsOf: view.subviews)
            topView = views.popLast()
        }

        var nodes = [(YogaNode, CGPoint)]()
        var topNode: (YogaNode, CGPoint)? = (self, CGPoint.zero)
        while true {
            guard let nodeWithOffset = topNode else {
                break
            }

            let node = nodeWithOffset.0
            let offset = nodeWithOffset.1

            if let tag = node.tag, let viewForTag = tagToView[tag], tag != 0 {
                viewForTag.frame = node.frame
                if viewForTag.superview == view {
                    viewForTag.frame.origin.x += offset.x
                    viewForTag.frame.origin.y += offset.y
                }
            }

            var newOffset = node.frame.origin
            newOffset.x += offset.x
            newOffset.y += offset.y

            let nodesWithOffset = node._subnodes.map { ($0, newOffset)}
            nodes.append(contentsOf: nodesWithOffset)
            topNode = nodes.popLast()
        }
    }

    // MARK: — Helpers

    private func updateStyle() {
        switch size.width.unit {
        case .point:
            YGNodeStyleSetWidth(_node, size.width.value)
        case .percent:
            YGNodeStyleSetWidthPercent(_node, size.width.value)
        case .undefined, .auto:
            break
        @unknown default:
            break
        }
        
        switch size.height.unit {
        case .point:
            YGNodeStyleSetHeight(_node, size.height.value)
        case .percent:
            YGNodeStyleSetHeightPercent(_node, size.height.value)
        case .undefined, .auto:
            break
        @unknown default:
            break
        }
        
        switch minSize.width.unit {
        case .point:
            YGNodeStyleSetMinWidth(_node, minSize.width.value)
        case .percent:
            YGNodeStyleSetMinWidthPercent(_node, minSize.width.value)
        case .undefined, .auto:
            break
        @unknown default:
            break
        }
        
        switch minSize.height.unit {
        case .point:
            YGNodeStyleSetMinHeight(_node, minSize.height.value)
        case .percent:
            YGNodeStyleSetMinHeightPercent(_node, minSize.height.value)
        case .undefined, .auto:
            break
        @unknown default:
            break
        }
        
        switch maxSize.width.unit {
        case .point:
            YGNodeStyleSetMaxWidth(_node, maxSize.width.value)
        case .percent:
            YGNodeStyleSetMaxWidthPercent(_node, maxSize.width.value)
        case .undefined, .auto:
            break
        @unknown default:
            break
        }
        
        switch maxSize.height.unit {
        case .point:
            YGNodeStyleSetMaxHeight(_node, maxSize.height.value)
        case .percent:
            YGNodeStyleSetMaxHeightPercent(_node, maxSize.height.value)
        case .undefined, .auto:
            break
        @unknown default:
            break
        }
        
        YGNodeStyleSetAspectRatio(_node, Float(aspectRatio))

        YGNodeStyleSetFlexDirection(_node, flexDirection)
        YGNodeStyleSetFlexWrap(_node, flexWrap)
        YGNodeStyleSetJustifyContent(_node, justifyContent)
        YGNodeStyleSetAlignContent(_node, alignContent)
        YGNodeStyleSetAlignItems(_node, alignItems)
        YGNodeStyleSetAlignSelf(_node, alignSelf)

        YGNodeStyleSetFlex(_node, Float(flex))
        YGNodeStyleSetFlexGrow(_node, Float(flexGrow))
        YGNodeStyleSetFlexShrink(_node, Float(flexShrink))
        
        switch flexBasis.unit {
        case .point:
            YGNodeStyleSetFlexBasis(_node, flexBasis.value)
        case .percent:
            YGNodeStyleSetFlexBasisPercent(_node, flexBasis.value)
        case .undefined:
            break
        case .auto:
            break
        @unknown default:
            break
        }

        YGNodeStyleSetDirection(_node, direction)
        YGNodeStyleSetOverflow(_node, overflow)
        YGNodeStyleSetPositionType(_node, positionType)

        setPosition(YGEdge.top, position.top)
        setPosition(YGEdge.bottom, position.bottom)
        setPosition(YGEdge.left, position.left)
        setPosition(YGEdge.right, position.right)

        setMargin(YGEdge.top, margin.top)
        setMargin(YGEdge.bottom, margin.bottom)
        setMargin(YGEdge.left, margin.left)
        setMargin(YGEdge.right, margin.right)

        setPadding(YGEdge.top, padding.top)
        setPadding(YGEdge.bottom, padding.bottom)
        setPadding(YGEdge.left, padding.left)
        setPadding(YGEdge.right, padding.right)

        YGNodeStyleSetBorder(_node, YGEdge.top, border.top.value)
        YGNodeStyleSetBorder(_node, YGEdge.bottom, border.bottom.value)
        YGNodeStyleSetBorder(_node, YGEdge.left, border.left.value)
        YGNodeStyleSetBorder(_node, YGEdge.right, border.right.value)

        YGNodeStyleSetDisplay(_node, isHidden ? .none : .flex)
    }
    
    private func setPosition(_ edge: YGEdge, _ value: YGValue) {
        switch value.unit {
        case .percent:
            YGNodeStyleSetPositionPercent(_node, edge, value.value)
        case .point:
            YGNodeStyleSetPosition(_node, edge, value.value)
        case .undefined:
            break
        case .auto:
            break
        @unknown default:
            break
        }
    }
    
    private func setMargin(_ edge: YGEdge, _ value: YGValue) {
        switch value.unit {
        case .percent:
            YGNodeStyleSetMarginPercent(_node, edge, value.value)
        case .point:
            YGNodeStyleSetMargin(_node, edge, value.value)
        case .undefined:
            break
        case .auto:
            break
        @unknown default:
            break
        }
    }
    
    private func setPadding(_ edge: YGEdge, _ value: YGValue) {
        switch value.unit {
        case .percent:
            YGNodeStyleSetPaddingPercent(_node, edge, value.value)
        case .point:
            YGNodeStyleSetPadding(_node, edge, value.value)
        case .undefined:
            break
        case .auto:
            break
        @unknown default:
            break
        }
    }
}
