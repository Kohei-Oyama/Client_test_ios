//
//  Color.swift
//  asukabu-taiwan
//
//  Created by Atsushi Ishibashi on 10/3/16.
//  Copyright © 2016 atsushi. All rights reserved.
//

import UIKit

struct Color {
    static let red: UIColor = UIColor(224, 0, 0)
    static let darkRed: UIColor = UIColor(125, 0, 0)
    static let gray: UIColor = UIColor(237, 237, 237)
    static let darkGray: UIColor = UIColor(153, 153, 153)

    struct String {
        static let black: UIColor = UIColor(51, 51, 51)
        static let gray: UIColor = UIColor(102, 102, 102)
    }

    struct Bet {
        static let buy: UIColor = UIColor(40, 209, 207)
        static let sell: UIColor = UIColor(255, 146, 88)
        static let none: UIColor = UIColor(237, 237, 237)

        static let lightBuy: UIColor = UIColor(190, 238, 237)
        static let lightSell: UIColor = UIColor(255, 196, 164)
    }

    struct Comment {
        static let gray: UIColor = UIColor(237, 237, 237)
    }
    struct Grade {
        static let gray: UIColor = UIColor(237, 237, 237)
    }
    struct Trade {
        static let gray: UIColor = UIColor(237, 237, 237)
    }
    struct News {
        static let gray: UIColor = UIColor(237, 237, 237)
    }
    struct School {
        static let pink: UIColor = UIColor(255, 100, 100)
        static let lightPink: UIColor = UIColor(255, 187, 187)
    }
}
