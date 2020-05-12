import Foundation
import UIKit
import Yoga
import YogaSwift

public class ImageLayout: WrappedViewLayout<UIImageView> {
    public init(image: UIImage?, configNode: ((YogaNode) -> Void)? = nil, configView: ((UIImageView) -> Void)? = nil) {
        super.init(            
            configNode: ({ node in
                if let size = image?.size {
                    node.size = YogaSize(size)
                }
                configNode?(node)
            }),
            configView: ({ view in
                view.image = image
                view.contentMode = .scaleAspectFit
                configView?(view)
            }))
    }
}
