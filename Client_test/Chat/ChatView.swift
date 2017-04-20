//
//  MainView.swift
//
//
//  Created by Hirano on 2017/04/02.
//
//

import Foundation
import UIKit
import SnapKit
import NextGrowingTextView

// チャットする画面
class ChatView : UIView, UIGestureRecognizerDelegate {
    
    var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero)
        tableView.backgroundColor = Color.clearBlue
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
        return tableView
    }()
    private var bottomLayoutConstraint: Constraint?
    private var topLayoutConstraint: Constraint?
    
    var inputTextView = InputTextView()
    var tapGesture: UITapGestureRecognizer?
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight = UINavigationController().navigationBar.frame.size.height
    var inputFieldHeight: CGFloat = 0
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.tableView)
        self.addSubview(self.inputTextView)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatView.tap(_:)))
        tapGesture!.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tableView.snp.remakeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(inputTextView.snp.top)
        }
        
        self.inputTextView.snp.remakeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.top.equalTo(tableView.snp.bottom)
            self.bottomLayoutConstraint = make.bottom.equalTo(self).constraint
            self.topLayoutConstraint = make.top.equalTo(tableView.snp.bottom).constraint
        }
        self.inputTextView.inputField.delegates.willChangeHeight = {(height: CGFloat) in
            if (self.inputFieldHeight != height) && (height > self.inputFieldHeight) {
                let difference = height - self.inputFieldHeight
                self.tableView.contentOffset.y = (self.tableView.contentSize.height - self.tableView.frame.height + difference)
                self.inputFieldHeight = height
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    func keyboardWillHideNotification(_ notification: Notification) {
        self.removeGestureRecognizer(self.tapGesture!)
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveLinear], animations: {
            self.bottomLayoutConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillShowNotification(_ notification: Notification) {
        self.inputFieldHeight = self.inputTextView.inputField.frame.height
        self.addGestureRecognizer(self.tapGesture!)
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = self.convert(keyboardEndFrame, from: self.window)
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, UIViewAnimationOptions.curveLinear], animations: {
            self.bottomLayoutConstraint?.update(offset: -convertedKeyboardEndFrame.height)
            self.layoutIfNeeded()
            if self.tableView.contentSize.height > (self.tableView.frame.height - self.navigationBarHeight - self.statusBarHeight){
                self.tableView.contentOffset.y = (self.tableView.contentSize.height - self.tableView.frame.height)
            }
        }, completion: nil)
    }
    
    func tap(_ sender: UITapGestureRecognizer){
        self.endEditing(true)
    }
}
