//
//  CustomLeftArrow.swift
//  Client_test
//
//  Created by Hirano on 2017/03/13.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

class CustomLeftArrow: UIView {
    override func draw(_ rect: CGRect) {
        let x: CGFloat = 0.0
        let y: CGFloat = rect.size.height / 2
        let x2: CGFloat = rect.size.width
        let y2: CGFloat = 0.0
        let x3: CGFloat = rect.size.width
        let y3: CGFloat = rect.size.height
        
        UIColor.black.setStroke()
        
        let line = UIBezierPath()
        line.lineWidth = 0.3
        
        line.move(to: CGPoint(x: x, y: y))
        line.addLine(to: CGPoint(x: x2, y: y2))
        line.stroke()
        
        let line2 = UIBezierPath()
        line2.lineWidth = 0.3
        
        line2.move(to: CGPoint(x: x3, y: y3))
        line2.addLine(to: CGPoint(x: x, y: y))
        line2.stroke()
    }
}
