import Foundation
import UIKit
import Yoga
import YogaSwift

public class TextLayout: BaseLayout<NSAttributedString, UILabel> {
    public init(model: NSAttributedString, configNode: ((YogaNode) -> Void)? = nil, configView: ((UILabel) -> Void)? = nil) {
        super.init(model: model, configNode: configNode, configView: configView)
    }

    public override func applyModel(to view: UILabel) {
        view.numberOfLines = 0
        view.lineBreakMode = .byClipping
        view.attributedText = model
    }

    public override func configNode(_ node: YogaNode) {
        super.configNode(node)
        node.contentSize = DefaultTextSizeMeasureFunc(for: self.model)
    }
}
