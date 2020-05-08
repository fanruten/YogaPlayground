import Foundation
import UIKit

extension NSAttributedString {

    /// Returns a new NSAttributedString with a given font and the same attributes.
    public func with(font: UIFont) -> NSAttributedString {
        let fontAttribute = [NSAttributedString.Key.font: font]
        let attributedTextWithFont = NSMutableAttributedString(string: string, attributes: fontAttribute)
        let fullRange = NSMakeRange(0, (string as NSString).length)
        attributedTextWithFont.beginEditing()
        self.enumerateAttributes(in: fullRange, options: .longestEffectiveRangeNotRequired, using: { (attributes, range, _) in
            attributedTextWithFont.addAttributes(attributes, range: range)
        })
        attributedTextWithFont.endEditing()

        return attributedTextWithFont
    }
}
