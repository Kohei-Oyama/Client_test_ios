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

// チャットのViewコントローラ
class MainViewController: UIViewController {
    
    let cellIdentifier = "MainCell"
    private let actionName = "speak"
    private let channelIdentifier: String = "MessageChannel"
    var channel: Channel?
    var history: Array<MainObject> = Array()
    var chatView: MainView?

    // 以下はRoomControllerから値をもらう
    var client: ActionCableClient?
    var userName: String = ""
    var roomName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewの設定
        chatView = MainView(frame: view.bounds)
        chatView?.backgroundColor = UIColor.gray
        chatView?.translatesAutoresizingMaskIntoConstraints = false
        chatView?.inputTextView.buttonTitle = "Send"
        chatView?.inputTextView.button.addTarget(self, action: #selector(self.sendPush), for: .touchUpInside)
        chatView?.tableView.delegate = self
        chatView?.tableView.dataSource = self
        chatView?.tableView.allowsSelection = false
        chatView?.tableView.register(MainCell.self, forCellReuseIdentifier: self.cellIdentifier)
        
        view.addSubview(chatView!)
        chatView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        
        //setupChannel()
    }
    
    // コントローラ起動時の初期設定
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
    
    // どこかタッチしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupChannel() -> Void {
        self.title = self.roomName
        let room_identifier = ["room" : self.roomName]
        // streamの切り替えや複製がどうしてもできない…
        self.channel = (client?.create(self.channelIdentifier, identifier: room_identifier, autoSubscribe: true, bufferActions: true))
        // 受信時の設定
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error)
                return
            }
            
            let JSONObject = JSON(data!)
            let msg = MainObject(name: JSONObject["userName"].string!, message: JSONObject["messageLog"].string!)
            self.history.append(msg)
            self.chatView?.tableView.reloadData()
            
            // 自分が発言したら一番下にスクロール
            if (msg.name == self.userName) {
                let indexPath = IndexPath(row: self.history.count - 1, section: 0)
                self.chatView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // Sendボタンを押した時のメソッド
    func sendPush() {
        let message = (self.chatView?.inputTextView.inputField.text)!
        // message前後の不要な改行と空白削除
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // 送信
        if (!(prettyMessage.isEmpty)) {
            self.channel?.action(self.actionName, with: ["userName": self.userName, "messageLog": prettyMessage])
        }
        self.chatView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
}

// UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    // MyCellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = history[(indexPath as NSIndexPath).row]
        let attrString = object.attributedString()
        let width = self.chatView?.tableView.bounds.size.width;
        // message(1行)が入るサイズ
        let rect = attrString.boundingRect(with: CGSize(width: width!, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        
        // messageのサイズ + Labelの上中下の余白 + 名前欄の高さ + Label中のtextの余白 + 1
        return rect.size.height + (MainCell.inset * 3.0) + MainCell.nameHeight + 16 + 1
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
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! MainCell
        let msg = history[(indexPath as NSIndexPath).row]
        cell.object = msg
        
        cell.messageLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(cell).offset(MainCell.inset)
            make.bottom.equalTo(cell).offset(-MainCell.inset)
        }
        
        cell.nameLabel.snp.remakeConstraints { (make) -> Void in
            make.top.left.equalTo(cell).offset(MainCell.inset)
            make.bottom.equalTo(cell.messageLabel.snp.top).offset(-MainCell.inset)
            make.height.equalTo(MainCell.nameHeight)
        }
        
        // 自分の発言は右側に出現
        if msg.name == self.userName {
            cell.messageLabel.snp.remakeConstraints { (make) -> Void in
                make.right.equalTo(cell).offset(-MainCell.inset)
                make.bottom.equalTo(cell).offset(-MainCell.inset)
            }
            
            cell.nameLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(cell).offset(MainCell.inset)
                make.right.equalTo(cell).offset(-MainCell.inset)
                make.bottom.equalTo(cell.messageLabel.snp.top).offset(-MainCell.inset)
                make.height.equalTo(MainCell.nameHeight)
            }
        }
        
        return cell
    }
}
