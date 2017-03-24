//
//  InputTextModel.swift
//  Chat_Client
//
//  Created by Hirano on 2017/03/17.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit
import NextGrowingTextView

class InputTextView: UIView{
    
    // ボタンとテキスト入力欄を持つUIView
    var bottom: NSLayoutConstraint!
    var inputField: NextGrowingTextView!
    var send: UIButton!
    
    required init() {
        super.init(frame: CGRect.zero)
        send = UIButton(frame: CGRect.zero)
        inputField = NextGrowingTextView(frame: CGRect.zero)
        self.addSubview(send)
        self.addSubview(inputField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
