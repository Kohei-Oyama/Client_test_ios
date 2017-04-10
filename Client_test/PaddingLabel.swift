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
    private let padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}
