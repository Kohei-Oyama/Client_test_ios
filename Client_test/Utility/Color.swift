//
//  Color.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/10.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit

// 0~255のRGBで色を作成
struct Color {
    static let clearBlue: UIColor = UIColor.rgb(r: 140, g: 233, b: 237, alpha: 1)
    static let clearYellow: UIColor = UIColor.rgb(r: 218, g: 227, b: 146, alpha: 1)
}

extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
