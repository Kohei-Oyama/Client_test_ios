//
//  MyCell.swift
//  Client_test
//
//  Created by Hirano on 2017/04/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SnapKit

class MyCell: UITableViewCell {
    
    static let inset:CGFloat = 10.0
    static let nameHeight:CGFloat = 20.0
    
    let messageLabel = UILabel()
    let nameLabel = UILabel()
    
    var message: Object? {
        didSet {
            // 値が変わったら行う処理
            self.messageLabel.attributedText = message?.attributedString()
            self.messageLabel.sizeToFit()
            self.nameLabel.text = self.message?.name
            self.nameLabel.sizeToFit()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // cellの初期スタイル
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        messageLabel.frame = CGRect.zero
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = UIColor.orange
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 2.0

        self.addSubview(messageLabel)
        
        nameLabel.frame = CGRect.zero
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameLabel.numberOfLines = 0
        
        self.addSubview(nameLabel)
        
        messageLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(MyCell.inset)
            make.bottom.right.equalTo(self).offset(-MyCell.inset)
        }
        
        nameLabel.snp.remakeConstraints { (make) -> Void in
            make.top.left.equalTo(self).offset(MyCell.inset)
            make.right.equalTo(self).offset(-MyCell.inset)
            make.bottom.equalTo(messageLabel.snp.top).offset(-MyCell.inset)
            make.height.equalTo(MyCell.nameHeight)
        }
        
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
