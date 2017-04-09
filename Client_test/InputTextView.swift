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
    
    // ボタンとテキスト入力欄を持つUIView
    var inputField: NextGrowingTextView!
    var button: UIButton!
    var buttonTitle: String = "" {
        didSet {
            // buttonTitleの値が変わったらタイトルセットしてサイズをフィットさせる
            self.button.setTitle(self.buttonTitle, for: .normal)
            self.button.titleLabel?.sizeToFit()
        }
    }
    
    required init() {
        super.init(frame: CGRect.zero)
        button = UIButton(frame: CGRect.zero)
        inputField = NextGrowingTextView(frame: CGRect.zero)
        self.addSubview(button)
        self.addSubview(inputField)
        
        inputField.snp.remakeConstraints { (make) -> Void in
            make.top.left.equalTo(self).offset(4)
            make.bottom.equalTo(self).offset(-4)
            make.right.equalTo(button.snp.left).offset(-4)
        }
        
        button.snp.remakeConstraints { (make) -> Void in
            make.bottom.right.equalTo(self).offset(-4)
        }
        
        inputField.layer.cornerRadius = 8
        inputField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        inputField.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        inputField.placeholderAttributedText = NSAttributedString(string: "テキストを入力してください",attributes: [NSFontAttributeName: inputField.font!,NSForegroundColorAttributeName: UIColor.gray])
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
