//
//  RoomCell.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SnapKit

// RoomCellが保有する情報
struct RoomCellValue {
    var roomName: String?
    var roomID: Int = 0
    var time: String?
    var messageNum: Int = 0
    
    // 文の設定
    func attributedString(sentence: String, num: Int?, fontSize: CGFloat?) -> NSAttributedString {
        var messageString = ""
        if num == nil {
            messageString = "\(sentence)"
        } else {
            messageString = "\(sentence)\n(\(num!))"
        }
        let messageRange = NSRange(location: 0, length: sentence.characters.count)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: messageString)
        if fontSize != nil {
            // FontSize
            string.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: fontSize!), range: messageRange)
        }
        return string
    }
}

class RoomCell: UITableViewCell {
    
    static let inset: CGFloat = 10.0
    static let nameFontSize: CGFloat = 14.0
    static let timeFontSize: CGFloat = 10.0
    
    var nameLabel: PaddingLabel = {
        let nameLabel = PaddingLabel(frame: CGRect.zero)
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameLabel.backgroundColor = Color.clearYellow
        nameLabel.layer.masksToBounds = true
        nameLabel.layer.cornerRadius = 10.0
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.adjustsFontSizeToFitWidth = false
        return nameLabel
    }()
    var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: CGRect.zero)
        timeLabel.numberOfLines = 2
        timeLabel.font = UIFont.boldSystemFont(ofSize: RoomCell.timeFontSize)
        timeLabel.textAlignment = NSTextAlignment.center
        return timeLabel
    }()
    
    var cellValue: RoomCellValue? {
        didSet {
            self.timeLabel.attributedText = cellValue?.attributedString(sentence: (cellValue?.time)!, num: cellValue?.messageNum, fontSize: nil)
            self.nameLabel.attributedText = cellValue?.attributedString(sentence: (cellValue?.roomName)!, num: nil, fontSize: RoomCell.nameFontSize)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // cellのスタイル
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)

        self.addSubview(timeLabel)
        self.addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
