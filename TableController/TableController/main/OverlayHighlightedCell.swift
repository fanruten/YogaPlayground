//
//  OverlayHighlightedCell.swift
//  AutoRuCellHelpers
//
//  Created by Ruslan V. Gumennyy on 31/10/2017.
//  Copyright © 2017 Auto.ru. All rights reserved.
//

import Foundation
import UIKit

open class OverlayHighlightedTableCell: UITableViewCell {
    private let overlay: UIView = UIView(frame: .zero)

    func updateOverlay(visible: Bool, animated: Bool) {
        overlay.removeFromSuperview()
        if visible {
            overlay.frame = bounds
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleBottomMargin]
            overlay.backgroundColor = .clear
            addSubview(overlay)

            UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                self.overlay.backgroundColor = UIColor(white: 229.0 / 255.0, alpha: 0.4)
            })
        }
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        updateOverlay(visible: selected, animated: animated)
    }

    open override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        updateOverlay(visible: highlighted, animated: animated)
    }
}

open class OverlayHighlightedCollectionCell: UICollectionViewCell {
    private let overlay: UIView = UIView(frame: .zero)

    func updateOverlay(visible: Bool, animated: Bool) {
        overlay.removeFromSuperview()
        if visible {
            overlay.frame = bounds
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleBottomMargin]
            overlay.backgroundColor = .clear
            addSubview(overlay)

            UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
                self.overlay.backgroundColor = UIColor(white: 229.0 / 255.0, alpha: 0.4)
            })
        }
    }

    override open var isSelected: Bool {
        didSet {
            updateOverlay(visible: isSelected, animated: true)
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            updateOverlay(visible: isHighlighted, animated: true)
        }
    }
}
