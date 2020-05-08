import Foundation
import UIKit
import Yoga
import YogaSwift

public class ImageLayout: BaseLayout<UIImage?, UIImageView> {
    public override init(model: UIImage?, childs: [Layout] = [], configNode: ((YogaNode) -> Void)? = nil, configView: ((UIImageView) -> Void)? = nil) {
        super.init(model: model,
                   childs: childs,
                   configNode: ({ node in
                        if let size = model?.size {
                            node.size = YogaSize(size)
                        }
                        configNode?(node)
                   }),
                   configView: configView)
    }

    public override func applyModel(to view: UIImageView) {
        view.image = model
        view.contentMode = .scaleAspectFit
    }
}
