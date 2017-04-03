//
//  Object.swift
//  Client_test
//
//  Created by Hirano on 2017/04/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

// Cellの中身
struct Object {
    var name: String
    //var time: String
    var message: String
    
    func attributedString() -> NSAttributedString {
        let messageString: String = "\(self.message)"
        let messageRange = NSRange(location: 0, length: self.message.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        // FontSize
        string.addAttribute(NSFontAttributeName,
                            value: UIFont.boldSystemFont(ofSize: 18.0),
                            range: messageRange)
        return string
    }
}
