//
//  CustomLeftTableViewCell.swift
//  Client_test
//
//  Created by Hirano on 2017/03/13.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

class CustomLeftTableViewCell: UITableViewCell
{
    var icon: UIImageView = UIImageView() // アイコン
    var name: UILabel = UILabel() // 名前
    var created: UILabel = UILabel() // 投稿日時
    
    var arrow: CustomLeftArrow = CustomLeftArrow() // 吹き出しの突起の部分
    var message: UILabel = UILabel() // 吹き出しの文字を表示している部分
    var viewMessage: UIView = UIView() // 吹き出しの枠部分
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        self.viewMessage.layer.borderColor = UIColor.gray.cgColor
        self.viewMessage.layer.borderWidth = 0.5
        self.viewMessage.layer.cornerRadius = 10.0
        self.viewMessage.backgroundColor = UIColor.yellow
        
        self.message.font = UIFont.systemFont(ofSize: 14)
        self.message.numberOfLines = 0
        self.message.backgroundColor = UIColor.green
        
        self.viewMessage.addSubview(self.message)
        self.contentView.addSubview(self.viewMessage)
        
        self.arrow.backgroundColor = UIColor.white
        self.arrow.backgroundColor = UIColor.red
        self.addSubview(self.arrow)
        
        self.icon.layer.borderColor = UIColor.black.cgColor
        self.icon.layer.borderWidth = 0.5
        
        self.addSubview(self.icon)
        
        self.name.font = UIFont.boldSystemFont(ofSize: 13)
        self.name.textAlignment = NSTextAlignment.left
        self.addSubview(self.name)
        
        self.created.font = UIFont.systemFont(ofSize: 13)
        self.created.textAlignment = NSTextAlignment.right
        self.addSubview(self.created)
    }
    
    func setData(widthMax: CGFloat,data: Dictionary<String,AnyObject>) -> CGFloat
    {
        let marginLeft: CGFloat = 60
        let marginRight: CGFloat = 0
        let marginVertical: CGFloat = 30
        
        // アイコン
        let xIcon: CGFloat = 3
        let yIcon: CGFloat = 3
        let widthIcon: CGFloat = 48
        let heightIcon: CGFloat = 48
        self.icon.frame = CGRect(x: xIcon, y: yIcon, width: widthIcon, height: heightIcon)
        self.icon.image = UIImage(named: (data["image"] as? String)!)
        self.icon.layer.cornerRadius = self.icon.frame.size.width * 0.5
        self.icon.clipsToBounds = true
        
        // 名前
        let xName: CGFloat = self.icon.frame.origin.x + self.icon.frame.size.width + 3
        let yName: CGFloat = self.icon.frame.origin.y
        let widthName: CGFloat = widthMax - (self.icon.frame.origin.x + self.icon.frame.size.width + 3)
        let heightName: CGFloat = 30
        self.name.text = data["name"] as? String
        self.name.frame = CGRect(x: xName, y: yName, width: widthName, height: heightName)
        
        // 投稿日時
        let xCreated: CGFloat = self.icon.frame.origin.x + self.icon.frame.size.width + 3
        let yCreated: CGFloat = self.icon.frame.origin.y
        let widthCreated: CGFloat = widthMax - (self.icon.frame.origin.x + self.icon.frame.size.width + 10)
        let heightCreated: CGFloat = 30
        self.created.text = data["created"] as? String
        self.created.frame = CGRect(x: xCreated, y: yCreated, width: widthCreated, height: heightCreated)
        
        let paddingHorizon: CGFloat = 10
        let paddingVertical: CGFloat = 10
        
        let widthLabelMax: CGFloat = widthMax - (marginLeft + marginRight + paddingHorizon * 2)
        
        let xMessageLabel: CGFloat = paddingHorizon
        let yMessageLabel: CGFloat = paddingVertical
        
        self.message.frame = CGRect(x: xMessageLabel, y: yMessageLabel, width: widthLabelMax, height: 0)
        self.message.text = data["message"] as? String
        self.message.sizeToFit()
        
        let xMessageView: CGFloat = marginLeft
        let yMessageView: CGFloat = marginVertical
        let widthMessageView: CGFloat = self.message.frame.size.width + paddingHorizon * 2
        let heightMessageView: CGFloat = self.message.frame.size.height + paddingVertical * 2
        self.viewMessage.frame = CGRect(x: xMessageView, y: yMessageView, width: widthMessageView, height: heightMessageView)
        
        let widthArrow: CGFloat = 10
        let heightArrorw: CGFloat = 10
        let xArrow: CGFloat = marginLeft - widthArrow + 1
        let yArrow: CGFloat = self.viewMessage.frame.origin.y + heightArrorw
        self.arrow.frame = CGRect(x: xArrow, y: yArrow, width: widthArrow, height: heightArrorw)
        
        let height: CGFloat = self.viewMessage.frame.height + marginVertical * 2
        return height
    }
}
