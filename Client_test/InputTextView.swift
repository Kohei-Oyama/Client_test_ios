//
//  InputTextModel.swift
//  Chat_Client
//
//  Created by Hirano on 2017/03/17.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NextGrowingTextView

class InputTextView: UIView{
    
    // Sendボタンとテキスト入力欄を持つUIView
    var inputField: NextGrowingTextView!
    var send: UIButton!
    
    required init() {
        super.init(frame: CGRect.zero)
        send = UIButton(frame: CGRect.zero)
        inputField = NextGrowingTextView(frame: CGRect.zero)
        self.addSubview(send)
        self.addSubview(inputField)
        
        inputField.snp.remakeConstraints { (make) -> Void in
            make.top.left.equalTo(self).offset(4)
            make.bottom.equalTo(self).offset(-4)
            make.right.equalTo(send.snp.left).offset(-4)
        }
        
        send.snp.remakeConstraints { (make) -> Void in
            make.bottom.right.equalTo(self).offset(-4)
            make.height.equalTo(36)
            make.width.equalTo(50)
        }
        
        inputField.layer.cornerRadius = 8
        inputField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        inputField.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        inputField.placeholderAttributedText = NSAttributedString(string: "テキストを入力してください",attributes: [NSFontAttributeName: inputField.font!,NSForegroundColorAttributeName: UIColor.gray])
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        send.setTitle("Send", for: .normal)
        send.setTitleColor(UIColor.white, for: .normal)
        send.backgroundColor = UIColor.blue
        send.layer.cornerRadius = 8
        send.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
