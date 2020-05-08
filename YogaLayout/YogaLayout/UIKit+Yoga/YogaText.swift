//
// Created by Ruslan V. Gumennyy on 17/08/2017.
// Copyright (c) 2017 facebook. All rights reserved.
//

import Foundation
import UIKit

public enum Text {
    case unattributed(String)
    case attributed(NSAttributedString)
}

extension Text {
    /// Calculate the text size within `maxSize` by given `UIFont`
    /// CGFloat.infinity mean unconstrained dimension
    /// boundingRect(with:options:attributes:) returns size to a precision of hundredths of a point,
    /// but UILabel only returns sizes with a point precision of 1/screenDensity.
    /// so you should round it up - CGSize(width: size.width.roundedUpToFractionalPoint, height: size.height.roundedUpToFractionalPoint)
    public func textSize(within maxSize: CGSize, font: UIFont? = nil) -> CGSize {
        let options: NSStringDrawingOptions = [
                .usesLineFragmentOrigin
        ]

        let size: CGSize
        switch self {
        case .attributed(let attributedText):
            if attributedText.length == 0 {
                return .zero
            }

            let text: NSAttributedString

            if let font = font {
                // UILabel/UITextView uses a default font if one is not specified in the attributed string.
                // boundingRect(with:options:attributes:) does not appear to have the same logic,
                // so we need to ensure that our attributed string has a default font.
                // We do this by creating a new attributed string with the default font and then
                // applying all of the attributes from the provided attributed string.
                text = attributedText.with(font: font)
            } else {
                text = attributedText
            }

            size = text.boundingRect(with: maxSize, options: options, context: nil).size
        case .unattributed(let text):
            if text.isEmpty {
                return .zero
            }

            if let font = font {
                size = text.boundingRect(with: maxSize, options: options, attributes: [NSAttributedString.Key.font: font], context: nil).size
            } else {
                fatalError("no provided font for plain string")
            }
        }

        return size
    }

    /// Return size for UILabel
    public func textSizeForLabel(within maxSize: CGSize, font: UIFont? = nil) -> CGSize {
        let size = textSize(within: maxSize, font: font)
        return CGSize(width: size.width.roundedUpToFractionalPoint, height: size.height.roundedUpToFractionalPoint)
    }
}
