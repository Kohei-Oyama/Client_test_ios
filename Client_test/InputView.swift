//
//  InputViewController.swift
//  Client_test
//
//  Created by Hirano on 2017/03/12.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import Foundation
import NextGrowingTextView

class InputView {
    
    var inputTextViewBottom: NSLayoutConstraint!
    var inputText: NextGrowingTextView!
    var view = UIView()
    
    func setview() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        inputText.layer.cornerRadius = 8
        inputText.backgroundColor = UIColor(white: 0.9, alpha: 1)
        inputText.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        inputText.placeholderAttributedText = NSAttributedString(string: "テキストを入力してください",attributes: [NSFontAttributeName: self.inputText.font!,NSForegroundColorAttributeName: UIColor.gray])
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inputTextViewBottom.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inputTextViewBottom.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
}
