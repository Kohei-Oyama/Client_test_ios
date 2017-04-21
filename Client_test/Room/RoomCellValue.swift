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
    var messageNum: Int = 0
    
    // 文の設定
    func attributedString(sentence: String, num: Int?, fontSize: CGFloat?) -> NSAttributedString {
        var messageString = ""
        if num == nil {
            messageString = "\(sentence)"
        } else {
            messageString = "\(sentence)\n(\(num!))"
        }
        let messageRange = NSRange(location: 0, length: sentence.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        if fontSize != nil {
        // FontSize
        string.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: fontSize!), range: messageRange)
        }
        return string
    }
}
