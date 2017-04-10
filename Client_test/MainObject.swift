//
//  Object.swift
//  Client_test
//
//  Created by Hirano on 2017/04/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

// MainCellの中身
struct MainObject {
    internal var name: String
    //var time: String
    internal var message: String
    
    // message本文の設定
    func attributedString() -> NSAttributedString {
        let messageString: String = "\(self.message)"
        let messageRange = NSRange(location: 0, length: self.message.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        // FontSize
        string.addAttribute(NSFontAttributeName,
                            value: UIFont.boldSystemFont(ofSize: 14.0),
                            range: messageRange)
        return string
    }
}
