import Foundation
import Yoga
import YogaSwift

public func SanitizeMeasurement(constrainedSize: CGFloat, measuredSize: CGFloat, measureMode: YGMeasureMode) -> CGFloat {
    switch measureMode {
    case .exactly:
        return constrainedSize
    case .atMost:
        return min(constrainedSize, measuredSize)
    case .undefined:
        return measuredSize
    @unknown default:
        return measuredSize
    }
}

public func DefaultTextSizeMeasureFunc(for string: NSAttributedString) -> YogaNode.ContentSizeMeasureFunc {
    return { (width: Float, widthMode: YGMeasureMode, height: Float, heightMode: YGMeasureMode) -> CGSize in
        let constrainedWidth: CGFloat = (widthMode == .undefined) ? CGFloat.greatestFiniteMagnitude : CGFloat(width)
        let constrainedHeight: CGFloat = (heightMode == .undefined) ? CGFloat.greatestFiniteMagnitude : CGFloat(height)
        
        let measuredSize = Text.attributed(string)
            .textSize(within: CGSize(width: constrainedWidth, height: constrainedHeight),
                      font: UIFont.systemFont(ofSize: 17))
        
        let contentSize = CGSize(width: SanitizeMeasurement(constrainedSize: constrainedWidth,
                                                            measuredSize: measuredSize.width,
                                                            measureMode: widthMode),
                                 height: SanitizeMeasurement(constrainedSize: constrainedHeight,
                                                             measuredSize: measuredSize.height,
                                                             measureMode: heightMode))
        return contentSize
    }
}
