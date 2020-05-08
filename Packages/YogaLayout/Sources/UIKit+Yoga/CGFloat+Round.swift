import Foundation
import UIKit

extension CGFloat {

    /**
     Returns the current float rounded up to the nearest fraction of a pixel
     that the screen density supports.
     */
    public var roundedUpToFractionalPoint: CGFloat {
        if self == 0 {
            return 0
        }
        if self < 0 {
            return -(-self).roundedDownToFractionalPoint
        }
        let scale = UIScreen.main.scale
        // The smallest precision in points (aka the number of points per hardware pixel).
        let pointPrecision = 1.0 / scale
        if self <= pointPrecision {
            return pointPrecision
        }
        return ceil(self * scale) / scale
    }

    /**
     Returns the current float rounded down to the nearest fraction of a pixel
     that the screen density supports.
     */
    public var roundedDownToFractionalPoint: CGFloat {
        if self == 0 {
            return 0
        }
        if self < 0 {
            return -(-self).roundedUpToFractionalPoint
        }
        let scale = UIScreen.main.scale
        // The smallest precision in points (aka the number of points per hardware pixel).
        let pointPrecision = 1.0 / scale
        if self < pointPrecision {
            return 0
        }
        return floor(self * scale) / scale
    }

    /**
     Returns the current float rounded up or down to the nearest fraction of a pixel
     that the screen density supports.
     */
    public var roundedToFractionalPoint: CGFloat {
        if self == 0 {
            return 0
        }
        let up = roundedUpToFractionalPoint
        let down = roundedDownToFractionalPoint
        return up - self <= self - down ? up : down
    }
}
