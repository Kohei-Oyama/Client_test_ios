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
    internal var inputField: NextGrowingTextView = {
        let field = NextGrowingTextView(frame: CGRect.zero)
        field.layer.cornerRadius = 8
        field.backgroundColor = UIColor(white: 0.9, alpha: 1)
        field.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        field.placeholderAttributedText = NSAttributedString(string: "テキストを入力してください",attributes: [NSFontAttributeName: field.font!,NSForegroundColorAttributeName: UIColor.gray])
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    internal var button: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
    }()
    
    internal var buttonTitle: String = "" {
        didSet {
            // buttonTitleの値が変わったらタイトルセットしてサイズをフィットさせる
            self.button.setTitle(self.buttonTitle, for: .normal)
            self.button.titleLabel?.sizeToFit()
        }
    }
    
    required init() {
        super.init(frame: CGRect.zero)
        
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
