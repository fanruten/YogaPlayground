import UIKit
import Yoga

public struct YogaSize {
    public var width: YGValue
    public var height: YGValue
    
    public init(width: YGValue, height: YGValue) {
        self.width = width
        self.height = height
    }
    
    public init(squareSize value: CGFloat) {
        self.width = YGValue(value)
        self.height = YGValue(value)
    }
    
    public init(_ size: CGSize) {
        self.width = YGValue(size.width)
        self.height = YGValue(size.height)
    }
    
    public static var nan: YogaSize {
        return YogaSize(width: YGValue.nan, height: YGValue.nan)
    }
}
