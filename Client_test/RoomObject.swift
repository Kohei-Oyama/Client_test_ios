//
//  RoomObject.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/10.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

// RoomCellの中身
struct RoomObject {
    var name: String
    var time: String
    
    // name本文の設定
    func nameAttributedString() -> NSAttributedString {
        let messageString: String = "\(self.name)"
        let messageRange = NSRange(location: 0, length: self.name.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        // FontSize
        string.addAttribute(NSFontAttributeName,
                            value: UIFont.boldSystemFont(ofSize: 14.0),
                            range: messageRange)
        return string
    }
    
    func timeAttributedString() -> NSAttributedString {
        let messageString: String = "\(self.time)"
        let messageRange = NSRange(location: 0, length: self.time.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        // FontSize
        string.addAttribute(NSFontAttributeName,
                            value: UIFont.boldSystemFont(ofSize: 10.0),
                            range: messageRange)
        return string
    }
}
