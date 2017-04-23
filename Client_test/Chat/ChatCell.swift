//
//  MyCell.swift
//  Client_test
//
//  Created by Hirano on 2017/04/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SnapKit

// ChatCellの保有する情報
struct ChatCellValue {
    var userName: String?
    var messageLog: String?
}

// チャット画面のCell
class ChatCell: UITableViewCell {
    
    static let inset: CGFloat = 9.0
    static let messageFontSize: CGFloat = 12.0
    static let nameFontSize: CGFloat = 15.0
    
    var messageLabel: PaddingLabel = {
        let messageLabel = PaddingLabel(frame: CGRect.zero)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 10.0
        messageLabel.textAlignment = NSTextAlignment.left
        messageLabel.adjustsFontSizeToFitWidth = false
        messageLabel.font = UIFont.boldSystemFont(ofSize: ChatCell.messageFontSize)
        return messageLabel
    }()
    var nameLabel: UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.numberOfLines = 1
        nameLabel.font = UIFont.boldSystemFont(ofSize: ChatCell.nameFontSize)
        return nameLabel
    }()
    
    var backView: UIImageView = {
        let backView = UIImageView(frame: CGRect.zero)
        var image = UIImage(named: "simple2")!
        // 画像の糊しろサイズ
        image = image.resizableImage(withCapInsets: UIEdgeInsetsMake(8, 18, 18, 10), resizingMode: UIImageResizingMode.tile)
        backView.contentMode = .scaleToFill
        backView.image = image
        return backView
    }()
    
    var object: ChatCellValue? {
        didSet {
            guard let message = object?.messageLog else { return }
            self.messageLabel.text = message
            self.nameLabel.text = self.object?.userName
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // cellの初期スタイル
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(backView)
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
