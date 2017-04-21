//
//  MyCell.swift
//  Client_test
//
//  Created by Hirano on 2017/04/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SnapKit

// チャット画面のCell
class ChatCell: UITableViewCell {
    
    static let inset: CGFloat = 10.0
    static let messageFontSize: CGFloat = 14.0
    static let nameFontSize: CGFloat = 15.0
    
    var messageLabel: PaddingLabel = {
        let messageLabel = PaddingLabel(frame: CGRect.zero)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.backgroundColor = UIColor.green
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 10.0
        messageLabel.textAlignment = NSTextAlignment.left
        messageLabel.adjustsFontSizeToFitWidth = false
        return messageLabel
    }()
    var nameLabel: UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.numberOfLines = 1
        nameLabel.font = UIFont.boldSystemFont(ofSize: ChatCell.nameFontSize)
        return nameLabel
    }()
    
    var object: ChatCellValue? {
        didSet {
            self.messageLabel.attributedText = object?.attributedString(sentence: (object?.messageLog)!, fontSize: ChatCell.messageFontSize)
            self.nameLabel.text = self.object?.userName
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // cellの初期スタイル
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(messageLabel)
        self.addSubview(nameLabel)
        
        self.backgroundColor = Color.clearBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
