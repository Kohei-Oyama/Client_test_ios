//
//  Object.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/11.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

// RoomCellが保有する情報
struct RoomCellValue {
    var roomName: String?
    var roomID: Int = 0
    var time: String?
    
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
