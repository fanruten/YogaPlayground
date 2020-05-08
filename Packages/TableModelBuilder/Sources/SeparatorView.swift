import YogaLayout
import UIKit
import Yoga

public enum EmptyCellHelperModel {
    case empty
}

public class SmallSeparatorLayout: WrappedViewLayout<SeparatorView> {
    public init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
                backgroundColor: UIColor? = nil) {
        
        super.init(
            configNode: ({ node in
                node.flexDirection = .column
                node.size.height = YGValue(1)
            }),
            configView: ({ (view) in
                view.isUserInteractionEnabled = false
                view.backgroundColor = backgroundColor
                view.leftInset = insets.left
                view.rightInset = insets.right
            }))
    }
}

public final class SmallSeparatorCellHelper: LayoutCellHelper<EmptyCellHelperModel> {

    public init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), backgroundColor: UIColor? = nil) {
        super.init(model: .empty) { (_) -> Layout in
            return SmallSeparatorLayout(insets: insets, backgroundColor: backgroundColor)
        }
    }
}

public final class BigSeparatorCellHelper: LayoutCellHelper<EmptyCellHelperModel> {

    public init(height: CGFloat, color: UIColor) {
        super.init(model: .empty) { (_) -> Layout in
            let layout = WrappedViewLayout<UIView>(
                configNode: ({ node in
                    node.size.height = YGValue(height)
                }),
                configView: ({ view in
                    view.backgroundColor = color
                })
            )
            return layout
        }
    }
}

public class SeparatorView: UIView {
    private let separator: UIView = UIView(frame: .zero)
    private let separatorHeight: CGFloat

    public var topInset: CGFloat
    public var leftInset: CGFloat
    public var rightInset: CGFloat

    public var separatorColor: UIColor? {
        set {
            separator.backgroundColor = newValue
        }
        get {
            return separator.backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        let scale = UIScreen.main.scale

        if abs(scale - 2.0) < CGFloat.ulpOfOne {
            separatorHeight = 0.5
        } else if abs(scale - 3.0) < CGFloat.ulpOfOne {
            separatorHeight = 0.33
        } else {
            separatorHeight = 1
        }

        topInset = 0
        leftInset = 0
        rightInset = 0
    
        separator.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)

        backgroundColor = .clear
        addSubview(separator)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        separator.frame = CGRect(x: leftInset, y: topInset, width: frame.width - leftInset - rightInset, height: separatorHeight)
    }
}
