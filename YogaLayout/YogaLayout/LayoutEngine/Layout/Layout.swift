import Foundation
import UIKit
import Yoga
import YogaSwift

public protocol Layout {
    func configNode(_ node: YogaNode)
    func configView(_ view: UIView)

    func createView() -> UIView
    var viewRequired: Bool { get }

    var children: [Layout] { get }
}
