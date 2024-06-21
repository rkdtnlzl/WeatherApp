//
//  UILabel+.swift
//  WeatherApp
//
//  Created by 강석호 on 6/21/24.
//

import UIKit

class PaddedLabel: UILabel {
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += textInsets.left + textInsets.right
        size.height += textInsets.top + textInsets.bottom
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.width += textInsets.left + textInsets.right
        sizeThatFits.height += textInsets.top + textInsets.bottom
        return sizeThatFits
    }
}
