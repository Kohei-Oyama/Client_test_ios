//
//  API.swift
//  asukabu-taiwan
//
//  Created by Atsushi Ishibashi on 10/3/16.
//  Copyright © 2016 atsushi. All rights reserved.
//

import Foundation

enum API {
    case Initialize

    var url: String {
        let host: String = "http://localhost:3000"
        switch self {
        case .Initialize:
            return "\(host)/api/initialize.json"
        }
    }
}
