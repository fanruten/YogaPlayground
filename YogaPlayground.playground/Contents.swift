import UIKit
import PlaygroundSupport
import YogaLayout
import Yoga
import YogaSwift

extension String {
    static let nbsp = "\u{00a0}"
}

let title = NSAttributedString(
    string: "Проверьте автомобиль\nперед покупкой",
    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)])

let subtitle = NSAttributedString(
    string: "Залоги, повреждения,\nДТП, ограничения и\(String.nbsp)данные о\(String.nbsp)пробеге",
    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)])


let layout = StackLayout(
    childs: [
        StackLayout(
            childs: [
                TextLayout(model: title,
                           configNode: ({ node in
                            node.margin = Edges(bottom: 8)
                           })),
                TextLayout(model: subtitle)
            ],
            configNode: ({ node in
                node.flexDirection = .column
            })
        ),
        ImageLayout(model: UIImage(named: "dude"),
                    configNode: ({ node in
                        node.size = YogaSize(width: 120, height: 120)
                    }))
    ],
    configNode: ({ node in
        node.flexDirection = .row
        node.padding = Edges(uniform: 8)
    })
)

let creator = BasicViewHierarchyCreator(rootComponent: layout, boundingSize: CGSize(width: 390, height: CGFloat.nan))
creator.calculateLayoutIfNeeded()
let view = creator.createView()

PlaygroundPage.current.liveView = view
