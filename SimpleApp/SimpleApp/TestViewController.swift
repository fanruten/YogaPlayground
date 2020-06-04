import UIKit
import YogaLayout
import Yoga
import YogaSwift
import TableController
import UIUtils

final class SimpleTableModelBuilder: BaseTableModelBuilder {
    
    /*
    func addHeader() {
        let cellHelper = LayoutCellHelper<String>(
            model: "",
            layoutCreator: ({ model in
                let title = NSAttributedString(
                    string: "Проверьте автомобиль\nперед покупкой",
                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)])
                
                let layout = StackLayout(
                    configNode: ({ node in
                        node.flexDirection = .row
                        node.flex = 1
                        node.padding = Edges(uniform: 8)
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
                            }))
                ])
                
                return layout
            }))
        
        addCellHelper(identifier: "header", cellHelper: cellHelper)
    }
 */
}
