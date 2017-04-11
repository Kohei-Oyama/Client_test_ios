//
//  Object.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/11.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

// Cellの中身
struct Object {
    var name: String?
    var time: String?
    var message: String?
    
    // 文の設定
    func attributedString(sentence: String, fontSize: CGFloat) -> NSAttributedString {
        let messageString: String = "\(sentence)"
        let messageRange = NSRange(location: 0, length: sentence.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        // FontSize
        string.addAttribute(NSFontAttributeName,
                            value: UIFont.boldSystemFont(ofSize: fontSize),
                            range: messageRange)
        return string
    }
}
