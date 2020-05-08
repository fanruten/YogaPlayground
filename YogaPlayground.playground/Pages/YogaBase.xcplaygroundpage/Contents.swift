import UIKit
import PlaygroundSupport
import YogaLayout
import Yoga
import YogaSwift
import UIUtils
import PlaygroundShim

let title = AttributedStringBuilder(text: "Проверьте автомобиль\nперед покупкой")
    .font(UIFont.systemFont(ofSize: 17, weight: .semibold))
    .string()

let subtitle = AttributedStringBuilder(text:"Залоги, повреждения,\nДТП, ограничения и\(String.nbsp)данные о\(String.nbsp)пробеге")
    .font(UIFont.systemFont(ofSize: 13, weight: .regular))
    .string()

let layout = StackLayout(
    configNode: ({ node in
        node.flexDirection = .row
        node.flex = 1
        node.padding = Edges(uniform: 8)
    }),
    children: [
        WrappedViewLayout<UIView>(
            configNode: ({ node in
                node.flexDirection = .column
                node.margin.right = 8                
            }),
            configView: ({ view in
                view.backgroundColor = .green
            }),
            children: [
                TextLayout(
                    text: title,
                    configNode: ({ node in
                        node.margin = Edges(bottom: 8)
                    }),
                    configView: ({ view in
                        view.layer.borderColor = UIColor.red.cgColor
                        view.layer.borderWidth = 1
                    })),
                TextLayout(
                    text: subtitle,
                    configView: ({ view in
                        view.layer.borderColor = UIColor.red.cgColor
                        view.layer.borderWidth = 1
                    }))
            ]
        ),
        ImageLayout(
            image: UIImage(named: "dude"),
            configNode: ({ node in
                node.size = YogaSize(width: 120, height: .nan)
                node.aspectRatio = 4/3
            }),
            configView: ({ view in
                view.layer.borderColor = UIColor.red.cgColor
                view.layer.borderWidth = 1
            }))
])

let creator = BasicViewHierarchyCreator(rootComponent: layout,
                                        boundingSize: CGSize(width: 390, height: CGFloat.nan))
creator.calculateLayoutIfNeeded()
let view = creator.createView()

PlaygroundPage.current.liveView = view
