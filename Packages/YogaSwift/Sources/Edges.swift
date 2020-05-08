import UIKit
import Yoga

public struct Edges {
    public var left: YGValue
    public var right: YGValue
    public var bottom: YGValue
    public var top: YGValue
    
    public init(left: CGFloat = 0.0, right: CGFloat = 0.0, bottom: CGFloat = 0.0, top: CGFloat = 0.0, unit: YGUnit = .point) {
        self.left = YGValue(value: Float(left), unit: unit)
        self.right = YGValue(value: Float(right), unit: unit)
        self.bottom = YGValue(value: Float(bottom), unit: unit)
        self.top = YGValue(value: Float(top), unit: unit)
    }
    
    public init(left: YGValue = 0.0, right: YGValue = 0.0, bottom: YGValue = 0.0, top: YGValue = 0.0) {
        self.left = left
        self.right = right
        self.bottom = bottom
        self.top = top
    }
    
    public init(top: YGValue, left: YGValue, bottom: YGValue, right: YGValue) {
        self.left = left
        self.right = right
        self.bottom = bottom
        self.top = top
    }
    
    public init(uniform: YGValue) {
        self.left = uniform
        self.right = uniform
        self.bottom = uniform
        self.top = uniform
    }
    
    public init(insets: UIEdgeInsets) {
        self.top = YGValue(insets.top)
        self.left = YGValue(insets.left)
        self.bottom = YGValue(insets.bottom)
        self.right = YGValue(insets.right)
    }
    
    public static let zero = Edges(uniform: 0.0)
    public static let undefined = Edges(uniform: YGValue.nan)
}
