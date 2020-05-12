import Foundation
import UIKit
import Yoga
import YogaSwift

public protocol ViewBuilder {
    func configView(_ view: UIView)
    func createView() -> UIView
}

public protocol Layout {
    func configNode(_ node: YogaNode)
    var viewBuilder: ViewBuilder? { get }
    var children: [Layout] { get }
}
