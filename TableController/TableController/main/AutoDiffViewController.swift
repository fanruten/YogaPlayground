import Foundation
import UIKit

public class AutoDiffViewController: UIViewController {

    private let instance: GenericAutoDiffViewController

    public init(identifier: String = "", cellWidthMeasure: AutoDiffCollectionController.CellWidthMeasure? = nil) {
        self.instance = CollectionAutoDiffViewController(identifier: identifier, cellWidthMeasure: cellWidthMeasure)

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        instance.setup()
        
        instance.scrollView.alwaysBounceVertical = true

        instance.scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instance.scrollView)
        instance.scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        instance.scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        instance.scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        instance.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true                
    }

    public var didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)? {
        get {
            return instance.didRequestLoadMore
        }
        set {
            instance.didRequestLoadMore = newValue
        }
    }

    public var willBeginDragging: (() -> Void)? {
        get {
            return instance.willBeginDragging
        }
        set {
            instance.willBeginDragging = newValue
        }
    }

    public var backgroundView: UIView? {
        get {
            return instance.backgroundView
        }
        set {
            instance.backgroundView = newValue
        }
    }

    public func tableItemWithIdentifier(_ identifier: String) -> TableItem? {
        return instance.tableItemWithIdentifier(identifier)
    }

    public func updateTableModel(with newModel: TableModel) {
        instance.updateTableModel(with: newModel)
    }

    public func updateTableModel(with newModelCreator: @escaping (() -> TableModel),
                                 completion: (() -> Void)? = nil,
                                 sync: Bool = false,
                                 animated: Bool = true) {
        instance.updateTableModel(with: newModelCreator, completion: completion, sync: sync, animated: animated)
    }

    public var scrollView: UIScrollView {
        loadViewIfNeeded()
        return instance.scrollView
    }

    public func scrollToItemWithIdentifier(_ identifier: String, scrollPosition: UICollectionView.ScrollPosition = .top, animated: Bool = true) {
        instance.scrollToItemWithIdentifier(identifier, scrollPosition: scrollPosition, animated: animated)
    }
}

protocol GenericAutoDiffViewController: class {
    var scrollView: UIScrollView { get }
    var backgroundView: UIView? { get set }

    var didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)? { get set }
    var willBeginDragging: (() -> Void)? { get set }
    
    func updateTableModel(with newModel: TableModel)
    func updateTableModel(with newModelCreator: @escaping (() -> TableModel), completion: (() -> Void)?, sync: Bool, animated: Bool)

    func tableItemWithIdentifier(_ identifier: String) -> TableItem?
    func scrollToItemWithIdentifier(_ itemId: String, scrollPosition: UICollectionView.ScrollPosition, animated: Bool)

    func setup()
}

public class CollectionAutoDiffViewController: GenericAutoDiffViewController {
    private let collectionController: AutoDiffCollectionController
    private var collectionView: UICollectionView?

    init(identifier: String, cellWidthMeasure: AutoDiffCollectionController.CellWidthMeasure? = nil) {
        self.collectionController = AutoDiffCollectionController(identifier: identifier, cellWidthMeasure: cellWidthMeasure)
    }

    // MARK: - AutoDiffViewControllerP

    public var backgroundView: UIView? {
        didSet {
            collectionView!.backgroundView = backgroundView
        }
    }

    public var scrollView: UIScrollView {
        return collectionView!
    }

    public var didRequestLoadMore: ((_ lastCellVisible: Bool) -> Void)? {
        set {
            var callbacks = collectionController.callbacks
            callbacks.didRequestLoadMore = newValue
            collectionController.callbacks = callbacks
        }
        get {
            return collectionController.callbacks.didRequestLoadMore
        }
    }

    public var willBeginDragging: (() -> Void)? {
        set {
            var callbacks = collectionController.callbacks
            callbacks.willBeginDragging = newValue
            collectionController.callbacks = callbacks
        }
        get {
            return collectionController.callbacks.willBeginDragging
        }
    }

    public func updateTableModel(with newModel: TableModel) {
        collectionController.updateTableModel(with: newModel)
    }

    public func updateTableModel(with newModelCreator: @escaping (() -> TableModel),
                                 completion: (() -> Void)? = nil,
                                 sync: Bool,
                                 animated: Bool) {
        collectionController.updateTableModel(with: newModelCreator(),
                                              completion: completion,
                                              sync: sync,
                                              animated: animated)
    }

    public func tableItemWithIdentifier(_ identifier: String) -> TableItem? {
        for section in collectionController.tableModel.sections {
            for item in section.items where item.identifier == identifier {
                return item
            }
        }

        return nil
    }

    public func setup() {
        class CustomFlowLayout: UICollectionViewFlowLayout {
            
            weak var collectionController: AutoDiffCollectionController?
            
            override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
                invalidateLayout()
                return true
            }
            
            override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
                let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

                attributes.flatMap {
                    collectionController?[itemIndexPath]?.cellHelper.collectionViewCellAttributes?.setupInitialCollectionAttributesForAppearing?($0)
                }

                return attributes
            }
            
            override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
                let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)

                attributes.flatMap {
                    collectionController?[itemIndexPath]?.cellHelper.collectionViewCellAttributes?.setupFinalCollectionAttributesForDisappearing?($0)
                }

                return attributes
            }
            
            override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
                let attributes = super.layoutAttributesForItem(at: indexPath)

                attributes.flatMap {
                    collectionController?[indexPath]?.cellHelper.collectionViewCellAttributes?.setupDefaultCollectionAttributes?($0)
                }

                return attributes
            }
            
            override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
                guard let attributesCollection = super.layoutAttributesForElements(in: rect) else {
                    return nil
                }
                
                for attributes in attributesCollection {
                    let indexPath = attributes.indexPath
                    if let item = collectionController?[indexPath] {
                        item.cellHelper.collectionViewCellAttributes?.setupDefaultCollectionAttributes?(attributes)
                    }
                }
                
                return attributesCollection
            }
        }

        let collectionViewLayout = CustomFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.collectionController = collectionController

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false

        collectionController.maxWidth = UIScreen.main.bounds.width
        collectionController.collectionView = collectionView

        self.collectionView = collectionView
    }

    func scrollToItemWithIdentifier(_ itemId: String, scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        self.collectionController.scrollToItemWithIdentifier(itemId, scrollPosition: scrollPosition, animated: animated)
    }
}
