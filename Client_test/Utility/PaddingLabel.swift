//
//  PaddingLabel.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/05.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit

//　周囲に余白を持ったUILabel
class PaddingLabel: UILabel {

    static let paddingSize: CGFloat = 8
    
    override func drawText(in rect: CGRect) {
        let padding = UIEdgeInsets(top: PaddingLabel.paddingSize, left: PaddingLabel.paddingSize, bottom: PaddingLabel.paddingSize, right: PaddingLabel.paddingSize)
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += 2 * PaddingLabel.paddingSize
        contentSize.width += 2 * PaddingLabel.paddingSize
        return contentSize
    }
}
