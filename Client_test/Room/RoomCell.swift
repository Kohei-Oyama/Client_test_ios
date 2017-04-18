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
// room名とCreate日時を表示
class RoomCell: UITableViewCell {
    
    static let inset:CGFloat = 10.0
    
    let nameLabel: PaddingLabel = {
        let nameLabel = PaddingLabel(frame: CGRect.zero)
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameLabel.numberOfLines = 0
        nameLabel.backgroundColor = Color.clearYellow
        nameLabel.layer.masksToBounds = true
        nameLabel.layer.cornerRadius = 10.0
        nameLabel.textAlignment = NSTextAlignment.center
        return nameLabel
    }()
    let timeLabel: PaddingLabel = {
        let timeLabel = PaddingLabel(frame: CGRect.zero)
        timeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        timeLabel.numberOfLines = 0
        timeLabel.backgroundColor = Color.clearBlue
        timeLabel.layer.masksToBounds = true
        timeLabel.layer.cornerRadius = 10.0
        timeLabel.textAlignment = NSTextAlignment.center
        return timeLabel
    }()
    
    var cellValue: RoomCellValue? {
        didSet {
            self.nameLabel.attributedText = cellValue?.attributedString(sentence: (cellValue?.roomName)!, fontSize: 18.0)
            self.nameLabel.sizeToFit()
            self.timeLabel.attributedText = cellValue?.attributedString(sentence: (cellValue?.time)!, fontSize: 12.0)
            self.timeLabel.sizeToFit()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // cellのスタイル
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameLabel)
        self.addSubview(timeLabel)
        
        //self.layoutMargins = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
