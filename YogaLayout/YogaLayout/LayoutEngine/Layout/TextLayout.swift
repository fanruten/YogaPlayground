import Foundation
import UIKit
import Yoga
import YogaSwift

public class TextLayout: WrappedViewLayout<UILabel> {
    public init(text: NSAttributedString, configNode: ((YogaNode) -> Void)? = nil, configView: ((UILabel) -> Void)? = nil) {
        super.init(
            children: [],
            configNode: ({ node in
                node.contentSize = DefaultTextSizeMeasureFunc(for: text)
                configNode?(node)
            }),
            configView: ({ view in
                view.numberOfLines = 0
                view.lineBreakMode = .byClipping
                view.attributedText = text
                configView?(view)
            }))
    }
}
