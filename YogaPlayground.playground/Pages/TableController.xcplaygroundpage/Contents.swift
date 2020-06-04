import UIKit
import PlaygroundSupport
import PlaygroundShim
import TableModelBuilder
import YogaLayout
import Yoga
import YogaSwift
import TableController
import UIUtils

let autoDiffViewController = AutoDiffViewController(identifier: "Test")
autoDiffViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)

let modelBuilder = SimpleTableModelBuilder()
modelBuilder.addHeader()
modelBuilder.addSeparatorItem(.medium)
modelBuilder.addTextButton(title: "ОК", onTap: ({
    print("Ok")
}))
modelBuilder.addSeparatorItem(.small)
modelBuilder.addTextButton(title: "Отмена", onTap: ({
    print("Cancel")
}))

autoDiffViewController.updateTableModel(with: TableModel(readyLoadMore: false, lastLoadFinishedWithError: false, sections: modelBuilder.build()))
autoDiffViewController.view.backgroundColor = .white

PlaygroundPage.current.liveView = autoDiffViewController.view
PlaygroundPage.current.needsIndefiniteExecution = true

final class SimpleTableModelBuilder: BaseTableModelBuilder {
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
}
