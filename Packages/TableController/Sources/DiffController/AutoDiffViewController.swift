import Foundation
import UIKit
import UIUtils

public class AutoDiffViewController: UIViewController {
    private let collectionController: AutoDiffCollectionController
    private var collectionView: UICollectionView?
    
    public init(identifier: String, cellWidthMeasure: AutoDiffCollectionController.CellWidthMeasure? = nil) {
        self.collectionController = AutoDiffCollectionController(identifier: identifier,
                                                                 cellWidthMeasure: cellWidthMeasure)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        scrollView.alwaysBounceVertical = true
        
        let backgroundView = UIView()
        view.addSubview(backgroundView)
        backgroundView.pin(.width).to(view).equal()
        backgroundView.pinToSuperView(.top).equal()
        backgroundView.pinToSuperView(.bottom).equal()
        backgroundView.pinToSuperView(.centerX).equal()
        
        view.addSubview(scrollView)
        scrollView.pinEdgesToSuperView()
    }
    
    // MARK: - Base
    
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
    
    public func scrollToItemWithIdentifier(_ itemId: String,
                                           scrollPosition: UICollectionView.ScrollPosition,
                                           animated: Bool) {
        self.collectionController.scrollToItemWithIdentifier(itemId,
                                                             scrollPosition: scrollPosition,
                                                             animated: animated)
    }
    
    private func setup() {
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
}
