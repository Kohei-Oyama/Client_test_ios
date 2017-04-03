//
//  MainController.swift
//  Client_test
//
//  Created by Hirano on 2017/04/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import ActionCableClient
import SnapKit
import SwiftyJSON

class MainViewController: UIViewController {
    
    let cellIdentifier = "MyCell"
    let channelIdentifier = "ChatChannel"
    
    var userName: String = ""
    let client = ActionCableClient(url: URL(string:"wss://actioncable-echo.herokuapp.com/cable")!)
    var channel: Channel?
    var history: Array<Object> = Array()
    var chatView: MainView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView = MainView(frame: view.bounds)
        setup(view: self.chatView!)
        view.addSubview(chatView!)
        
        chatView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        
        chatView?.tableView.delegate = self
        chatView?.tableView.dataSource = self
        chatView?.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        chatView?.tableView.allowsSelection = false
        chatView?.tableView.register(MyCell.self, forCellReuseIdentifier: self.cellIdentifier)
        
        setupClient()
    }
    
    // アプリ起動時の初期設定
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(title: "Setting Name", message: "What's Your Name?", preferredStyle: UIAlertControllerStyle.alert)
        var nameTextField: UITextField?
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Your Name"
            nameTextField = textField
        })
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler: {action in
            self.userName = (nameTextField?.text)!
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController {
    
    func setupClient() -> Void {
        
        self.client.onConnected = {
            print("Connected!")
        }
        
        self.channel = client.create(self.channelIdentifier)
        // 受信時の設定
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error)
                return
            }
            
            let JSONObject = JSON(data!)
            let msg = Object(name: JSONObject["name"].string!, message: JSONObject["message"].string!)
            self.history.append(msg)
            self.chatView?.tableView.reloadData()
            
            // 自分が発言したら一番下にスクロール
            if (msg.name == self.userName) {
                let indexPath = IndexPath(row: self.history.count - 1, section: 0)
                self.chatView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        // サーバと接続
        self.client.connect()
    }
    
    func setup(view: MainView) {
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Sendした時のイベントを追加
        view.inputTextView.send.addTarget(self, action: #selector(self.sendPush), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // どこかタッチしたらキーボード閉じる
        self.view.endEditing(true)
    }
    
    func sendPush() {
        // Sendボタンを押した時のメソッド
        let message = (self.chatView?.inputTextView.inputField.text)!
        // message前後の不要な改行と空白削除
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyMessage.isEmpty)) {
            print("Sending Message: \(message)")
            _ = self.channel?.action("talk", with:
                ["name": self.userName, "message": prettyMessage]
            )
        }
        self.chatView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
}

// UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    // Cellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = history[(indexPath as NSIndexPath).row]
        let attrString = message.attributedString()
        let width = self.chatView?.tableView.bounds.size.width;
        // message(1行)が入るサイズ
        let rect = attrString.boundingRect(with: CGSize(width: width!, height: CGFloat.greatestFiniteMagnitude),
                                           options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        // messageのサイズ + 上下の余白 + 名前欄の高さ
        return rect.size.height + (MyCell.inset * 3.0) + MyCell.nameHeight
    }
}

// UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    // Cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    // Cellの中身設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! MyCell
        let msg = history[(indexPath as NSIndexPath).row]
        cell.message = msg
        return cell
    }
}
