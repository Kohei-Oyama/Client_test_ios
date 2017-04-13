//
//  URL.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/12.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation

enum myURL {

    case Local
    case Finatext
    case Hirose
    
    var url: String {
        let host: String = "ws://localhost:3000"
        let finatext: String = "ws://192.168.12.126:3000"
        let hirose: String = "ws://157.82.6.240:3000"
        switch self {
        case .Local:
            return "\(host)/cable"
        case .Finatext:
            return "\(finatext)/cable"
        case .Hirose:
            return "\(hirose)/cable"
        }
    }
}
