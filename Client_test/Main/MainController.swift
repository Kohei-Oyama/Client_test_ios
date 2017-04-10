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
    
    internal let cellIdentifier = "MainCell"
    private let actionName = "speak"
    private var channel: Channel?
    internal var history: Array<MainObject> = Array()
    internal var chatView: MainView?

    // 以下はRoomControllerから値をもらう
    // channelIdentifierにはRoom名が入るはず(ログが欲しい)
    // channel名で区別せずに送受信のJSONに"room"変数作ってそこで呼び出すDBを指定すべき?
    // Cellを押した時にRoom名をサーバに送信し、その名前のchannelが作成できれば良い
    internal var channelIdentifier: String = ""
    internal var client = ActionCableClient(url: URL(string: "test")!)
    internal var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.channelIdentifier
        
        // テスト段階のためチャンネル名固定
        channelIdentifier = "MessageChannel"
        
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
        
        setupChannel()
    }
    
    // コントローラ起動時の初期設定
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // どこかタッチしたらキーボード閉じる
        self.view.endEditing(true)
    }
    
    private func setupChannel() -> Void {
        
        // Room名のchannel作成
        self.channel = client.create(self.channelIdentifier)
        // 受信時の設定
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error)
                return
            }
            
            let JSONObject = JSON(data!)
            let msg = MainObject(name: JSONObject["name"].string!, message: JSONObject["message"].string!)
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
    internal func sendPush() {
        let message = (self.chatView?.inputTextView.inputField.text)!
        // message前後の不要な改行と空白削除
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // 送信
        if (!(prettyMessage.isEmpty)) {
            self.channel?.action(self.actionName, with: ["name": self.userName, "message": prettyMessage])
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
