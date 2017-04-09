//
//  RoomCell.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SnapKit

// チャットのテーブルの1つのCell
class RoomCell: UITableViewCell {
    
    static let inset:CGFloat = 10.0
    static let nameHeight:CGFloat = 20.0
    
    let roomLabel = PaddingLabel()
    
    var object: Object? {
        didSet {
            // objectの値が変わったら行う処理
            self.roomLabel.attributedText = object?.attributedString()
            self.roomLabel.sizeToFit()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // cellの初期スタイル
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        roomLabel.frame = CGRect.zero
        roomLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        roomLabel.numberOfLines = 0
        roomLabel.backgroundColor = UIColor.red
        roomLabel.layer.masksToBounds = true
        roomLabel.layer.cornerRadius = 10.0
        roomLabel.textAlignment = NSTextAlignment.center
        
        self.addSubview(roomLabel)
        
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
