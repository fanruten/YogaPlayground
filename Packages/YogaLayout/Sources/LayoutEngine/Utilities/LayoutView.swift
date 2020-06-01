import Foundation
import UIKit

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
