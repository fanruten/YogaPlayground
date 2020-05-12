import Foundation
import UIKit

public class LayoutContainerView: UIScrollView {

    private let layout: Layout
    private let unconstrainedHeight: Bool    
    private var layoutView: UIView?
    private var prevSize: CGSize?

    public init(layout: Layout, unconstrainedHeight: Bool = false) {
        self.layout = layout
        self.unconstrainedHeight = unconstrainedHeight

        super.init(frame: .zero)

        alwaysBounceVertical = true
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard prevSize != bounds.size else {
            return
        }
        prevSize = bounds.size

        UIView.performWithoutAnimation {
            self.layoutView?.removeFromSuperview()
            
            let creator = BasicViewHierarchyCreator(rootComponent: layout,
                                                    boundingSize: CGSize(width: bounds.size.width,
                                                                         height: unconstrainedHeight ? .nan : bounds.size.height))
            let layoutView = creator.createView()
            addSubview(layoutView)
            self.layoutView = layoutView
            
            self.contentSize = layoutView.bounds.size
        }
    }
}

public class LayoutView: UIView {
    public enum SizeConstraint {
        case width
        case height
    }

    private let layout: Layout
    private let sizeConstraints: Set<SizeConstraint>

    private var contentSize: CGSize = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public init(layout: Layout, sizeConstraints: Set<SizeConstraint> = [.width]) {
        self.layout = layout
        self.sizeConstraints = sizeConstraints
        
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        let creator = BasicViewHierarchyCreator(
            rootComponent: layout,
            boundingSize: CGSize(
                width: sizeConstraints.contains(.width) ? bounds.size.width : .nan,
                height: sizeConstraints.contains(.height) ? bounds.size.height : .nan
            )
        )
        
        subviews.forEach {
            $0.removeFromSuperview()
        }
        addSubview(creator.createView())
        contentSize = creator.viewSize
    }

    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
