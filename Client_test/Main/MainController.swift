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

    private let channelIdentifier: String = "MessageChannel"
    private let actionNameChat = "chat"
    private let actionNameChange = "change"
    let cellName = "MainCell"
    var channel: Channel?
    var log: Array<Object> = Array()
    var chatView: MainView?
    var client: ActionCableClient?
    var userName: String?
    var roomName: String? {
        didSet {
            // roomNameの値が変わったら行う
            resetChannel(roomName: roomName!)
        }
    }
    
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
        chatView?.tableView.register(MainCell.self, forCellReuseIdentifier: self.cellName)
        
        view.addSubview(chatView!)
        chatView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
    }
    
    // コントローラ起動時の初期設定
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // どこかタッチしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func resetChannel(roomName: String) -> Void {
        self.title = roomName
        // channelのstreamを変更
        let room_identifier = ["roomID" : roomName]
        self.channel?.unsubscribe()
        self.channel = (client?.create(self.channelIdentifier, identifier: room_identifier, autoSubscribe: false, bufferActions: true))
        self.channel?.subscribe()
        // 受信処理
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error as! String)
                return
            }
            
            let JSONObject = JSON(data!)
            let msg = Object(name: JSONObject["userName"].string!, time: nil, message: JSONObject["messageLog"].string!)
            self.log.append(msg)
            self.chatView?.tableView.reloadData()
            // 自分が発言したら一番下にスクロール
            if (msg.name == self.userName) {
                let indexPath = IndexPath(row: self.log.count - 1, section: 0)
                self.chatView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        // RoomのLog読み取り
        self.log = []
        // ↓DBからちゃんと送られてくれば本来は不要
        self.chatView?.tableView.reloadData()
        self.channel?.action(self.actionNameChange, with: room_identifier)
    }
    
    // Send
    func sendPush() {
        let message = (self.chatView?.inputTextView.inputField.text)!
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyMessage.isEmpty)) {
            self.channel?.action(self.actionNameChat, with: ["userName": self.userName!, "messageLog": prettyMessage])
        }
        self.chatView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
}

// UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    // MyCellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = log[(indexPath as NSIndexPath).row]
        let attrString = object.attributedString(sentence: object.message!, fontSize: 14.0)
        let width = self.chatView?.tableView.bounds.size.width;
        let rect = attrString.boundingRect(with: CGSize(width: width!, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        
        // messageのサイズ + Labelの上中下の余白 + 名前欄の高さ + Label中のtextの余白 + 1
        return rect.size.height + (MainCell.inset * 3.0) + MainCell.nameHeight + 16 + 1
    }
}

// UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    // Cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return log.count
    }
    
    // Cellの中身設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellName, for: indexPath) as! MainCell
        let msg = log[(indexPath as NSIndexPath).row]
        cell.object = msg
        
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
        } else {
            cell.messageLabel.snp.remakeConstraints { (make) -> Void in
                make.left.equalTo(cell).offset(MainCell.inset)
                make.bottom.equalTo(cell).offset(-MainCell.inset)
            }
            
            cell.nameLabel.snp.remakeConstraints { (make) -> Void in
                make.top.left.equalTo(cell).offset(MainCell.inset)
                make.bottom.equalTo(cell.messageLabel.snp.top).offset(-MainCell.inset)
                make.height.equalTo(MainCell.nameHeight)
            }
        }
        return cell
    }
}
