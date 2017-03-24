//
//  ViewController.swift
//  Client_test
//
//  Created by Hirano on 2017/03/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SwiftSocket
import SwiftyJSON
import NextGrowingTextView
import JSQMessagesViewController

class ViewController: UIViewController {
    
    let host = "localhost"
    let port: Int32 = 8083
    let userName = "Oyama"
    var client: JSONSocket!
    
    var inputTextView: InputTextView!
    var outputTextView: OutputTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.gray
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // 入力部分をViewに追加
        self.inputTextView = InputTextView()
        setupInput(view: self.inputTextView)
        self.view.addSubview(self.inputTextView)

        // 出力部分をViewに追加
        self.outputTextView = OutputTextView()
        setupOutput(view: self.outputTextView)
        self.view.addSubview(self.outputTextView)
        
        // inputViewのConstraint
        inputTextView.bottom = NSLayoutConstraint(item: inputTextView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        var left = NSLayoutConstraint(item: inputTextView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        var width = NSLayoutConstraint(item: inputTextView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        
        view.addConstraint(inputTextView.bottom)
        view.addConstraint(left)
        view.addConstraint(width)
        
        // outputViewのConstraint
        var top = NSLayoutConstraint(item: outputTextView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 40)
        
        var height = NSLayoutConstraint(item: outputTextView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0, constant: 300)
        
        left = NSLayoutConstraint(item: outputTextView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 7)
        
        var right = NSLayoutConstraint(item: outputTextView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -8)
        
        view.addConstraint(top)
        view.addConstraint(height)
        view.addConstraint(left)
        view.addConstraint(right)
        
        // outputTextのConstraint
        top = NSLayoutConstraint(item: outputTextView.textView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: outputTextView.connect, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        var bottom = NSLayoutConstraint(item: outputTextView.textView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        left = NSLayoutConstraint(item: outputTextView.textView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        right = NSLayoutConstraint(item: outputTextView.textView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        view.addConstraint(top)
        view.addConstraint(bottom)
        view.addConstraint(left)
        view.addConstraint(right)
        
        // ConnectのConstraint
        top = NSLayoutConstraint(item: outputTextView.connect, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        height = NSLayoutConstraint(item: outputTextView.connect, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.height, multiplier: 0, constant: 36)
        
        left = NSLayoutConstraint(item: outputTextView.connect, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        right = NSLayoutConstraint(item: outputTextView.connect, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: outputTextView.end, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        view.addConstraint(top)
        view.addConstraint(height)
        view.addConstraint(left)
        view.addConstraint(right)

        // EndのConstraint
        top = NSLayoutConstraint(item: outputTextView.end, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        height = NSLayoutConstraint(item: outputTextView.end, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.height, multiplier: 0, constant: 36)
        
        right = NSLayoutConstraint(item: outputTextView.end, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: outputTextView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        width = NSLayoutConstraint(item: outputTextView.end, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: outputTextView.connect, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        
        view.addConstraint(top)
        view.addConstraint(height)
        view.addConstraint(right)
        view.addConstraint(width)

        
        // inputTextFieldのConstraint
        bottom = NSLayoutConstraint(item: inputTextView.inputField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -4)
        
        top = NSLayoutConstraint(item: inputTextView.inputField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 4)
        
        left = NSLayoutConstraint(item: inputTextView.inputField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 8)
        
        width = NSLayoutConstraint(item: inputTextView.inputField, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: -80)
        
        view.addConstraint(bottom)
        view.addConstraint(top)
        view.addConstraint(left)
        view.addConstraint(width)
        
        // SendのConstraint
        bottom = NSLayoutConstraint(item: inputTextView.send, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -4)
        
        height = NSLayoutConstraint(item: inputTextView.send, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.height, multiplier: 0, constant: 36)
        
        left = NSLayoutConstraint(item: inputTextView.send, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: inputTextView.inputField, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 7)
        
        right = NSLayoutConstraint(item: inputTextView.send, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: inputTextView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -8)
        
        view.addConstraint(bottom)
        view.addConstraint(height)
        view.addConstraint(left)
        view.addConstraint(right)
        
        client = JSONSocket(username: userName, address: host, port: port)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // どこかタッチしたらキーボード閉じる
        self.view.endEditing(true)
    }
    
    func keyboardWillHide(_ sender: Notification) {
        // キーボード閉じた時のメソッド
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                inputTextView.bottom.constant =  0
                updateViewConstraints()
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    
    func keyboardWillShow(_ sender: Notification) {
        // キーボード現れた時のメソッド
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                inputTextView.bottom.constant = -keyboardHeight
                updateViewConstraints()
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func connectPush() {
        // Connectボタンを押した時のメソッド
        if client.connect() == true {
            client.receive(view: self.outputTextView.textView)
        }
    }

    func endPush() {
        // Endボタンを押した時のメソッド
        client.close()
        print("End connect")
    }
    
    func sendPush() {
        // Sendボタンを押した時のメソッド
        client.send(text: self.inputTextView.inputField.text, view: self.outputTextView.textView)
        self.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
    func setupInput(view: InputTextView) {
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.inputField.layer.cornerRadius = 8
        view.inputField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.inputField.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        view.inputField.placeholderAttributedText = NSAttributedString(string: "テキストを入力してください",attributes: [NSFontAttributeName: self.inputTextView.inputField.font!,NSForegroundColorAttributeName: UIColor.gray])
        view.inputField.translatesAutoresizingMaskIntoConstraints = false
        
        view.send.setTitle("Send", for: .normal)
        view.send.setTitleColor(UIColor.white, for: .normal)
        view.send.backgroundColor = UIColor.blue
        view.send.layer.cornerRadius = 8
        view.send.translatesAutoresizingMaskIntoConstraints = false
        // イベントを追加
        view.send.addTarget(self, action: #selector(self.sendPush), for: .touchUpInside)
    }
    
    func setupOutput(view: OutputTextView) {
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.textView.isEditable = false
        view.textView.backgroundColor = UIColor.white
        view.textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.connect.setTitle("Connect", for: .normal)
        view.connect.setTitleColor(UIColor.white, for: .normal)
        view.connect.backgroundColor = UIColor.blue
        view.connect.layer.cornerRadius = 8
        view.connect.translatesAutoresizingMaskIntoConstraints = false
        // イベントを追加
        view.connect.addTarget(self, action: #selector(self.connectPush), for: .touchUpInside)

        view.end.setTitle("End", for: .normal)
        view.end.setTitleColor(UIColor.white, for: .normal)
        view.end.backgroundColor = UIColor.blue
        view.end.layer.cornerRadius = 8
        view.end.translatesAutoresizingMaskIntoConstraints = false
        // イベントを追加
        view.end.addTarget(self, action: #selector(self.endPush), for: .touchUpInside)
    }
}
