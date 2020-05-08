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


let subtitle = AttributedStringBuilder(text: "Нажми меня")
    .font(UIFont.systemFont(ofSize: 13, weight: .regular))
    .string()


var views = [String:UIView]()

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
            children: [
                TextLayout(
                    text: title,
                    configNode: ({ node in
                        node.margin = Edges(bottom: 8)
                        node.size.height = 60
                    }),
                    configView: ({ view in
                        view.layer.borderColor = UIColor.red.cgColor
                        view.layer.borderWidth = 1
                    })),
                TextLayout(
                    text: subtitle,
                    configNode: ({ node in
                        node.alignSelf = .center
                    }),
                    configView: ({ view in
                        view.layer.borderColor = UIColor.red.cgColor
                        view.layer.borderWidth = 1
                        view.backgroundColor = .green
                        
                        view.aru_addTapHandler {
                            guard let imageView = views["image"] else {
                                return
                            }
                            
                            UIView.animate(withDuration: 0.4) {
                                imageView.transform = imageView.transform.rotated(by: CGFloat.pi / 2)
                            }
                        }
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
                views["image"] = view
            }))
])

let creator = BasicViewHierarchyCreator(rootComponent: layout,
                                        boundingSize: CGSize(width: 390, height: CGFloat.nan))
creator.calculateLayoutIfNeeded()
let view = creator.createView()

PlaygroundPage.current.liveView = view
