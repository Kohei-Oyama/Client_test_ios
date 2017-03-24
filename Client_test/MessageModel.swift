//
//  MessageModel.swift
//  Client_test
//
//  Created by Hirano on 2017/03/14.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation

class MessageModel: NSObject {
    let name: String
    let message: String
    
    init(name: String, message: String) {
        self.name = name
        self.message = message
    }
}
