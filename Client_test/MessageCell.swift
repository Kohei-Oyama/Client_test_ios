//
//  MessageCell.swift
//  Client_test
//
//  Created by Hirano on 2017/03/14.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    var nameLabel: UILabel!
    var messageLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .left
        
        messageLabel = UILabel(frame: CGRect.zero)
        messageLabel.textAlignment = .left
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
        
    func setCell(object: MessageModel) {
        nameLabel.text = object.name
        contentView.addSubview(nameLabel)
        messageLabel.text = object.message
        contentView.addSubview(messageLabel)
    }
}
