import Foundation
import Yoga

postfix operator %

extension Int {
    public static postfix func % (value: Int) -> YGValue {
        return YGValue(value: Float(value), unit: .percent)
    }
}

extension YGValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public init(integerLiteral value: Int) {
        self = YGValue(value: Float(value), unit: .point)
    }
    
    public init(floatLiteral value: Float) {
        self = YGValue(value: value, unit: .point)
    }
    
    public init(_ value: CGFloat) {
        self = YGValue(value: Float(value), unit: .point)
    }
    
    public static var nan: YGValue {
        return YGValue(value: Float.nan, unit: .point)
    }
}

extension YGValue: Equatable {
    public static func ==(lhs: YGValue, rhs: YGValue) -> Bool {
        return lhs.value == rhs.value && lhs.unit == rhs.unit
    }
}
