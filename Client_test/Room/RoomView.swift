//
//  RoomView.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NextGrowingTextView

// Roomを作る画面
class RoomView : UIView {
    
    var tableView: UITableView
    var bottomLayoutConstraint: Constraint?
    var inputTextView: InputTextView!
    
    required override init(frame: CGRect) {
        self.tableView = UITableView()
        self.inputTextView = InputTextView()
        super.init(frame: frame)
        
        self.tableView.frame = CGRect.zero
        self.addSubview(self.tableView)
        
        self.addSubview(self.inputTextView)
        
        self.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.snp.remakeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(inputTextView.snp.top)
        }
        
        inputTextView.snp.remakeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.top.equalTo(tableView.snp.bottom)
            self.bottomLayoutConstraint = make.bottom.equalTo(self).constraint
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}


extension RoomView {
    func keyboardWillHideNotification(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rawAnimationCurve = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.bottomLayoutConstraint?.update(offset: 0)
            self.updateConstraintsIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillShowNotification(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = self.convert(keyboardEndFrame, from: self.window)
        let rawAnimationCurve = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.bottomLayoutConstraint?.update(offset: -convertedKeyboardEndFrame.height)
            self.updateConstraintsIfNeeded()
        }, completion: nil)
    }
}
