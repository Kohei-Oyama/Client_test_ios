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
    
    internal let cellIdentifier = "MyCell"
    private let actionName = "speak"
    
    internal var userName: String = ""
    internal var channelIdentifier: String = ""
    //let client = ActionCableClient(url: URL(string:"ws://192.168.11.5:3000/cable")!)
    //let client = ActionCableClient(url: URL(string:"ws://10.213.225.68:3000/cable")!)
    private let client = ActionCableClient(url: URL(string:"ws://localhost:3000/cable")!)
    //let client = ActionCableClient(url: URL(string:"wss://actioncable-echo.herokuapp.com/cable")!)
    private var channel: Channel?
    internal var history: Array<MainObject> = Array()
    internal var chatView: MainView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.channelIdentifier
        
        // テスト段階のためチャンネル名固定
        //channelIdentifier = "ChatChannel"
        channelIdentifier = "MessageChannel"
        
        // viewの設定
        chatView = MainView(frame: view.bounds)
        setup(view: self.chatView!)
        view.addSubview(chatView!)
        chatView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        
        chatView?.tableView.delegate = self
        chatView?.tableView.dataSource = self
        chatView?.tableView.allowsSelection = false
        chatView?.tableView.register(MainCell.self, forCellReuseIdentifier: self.cellIdentifier)
        
        setupClient()
    }
    
    // コントローラ起動時の初期設定
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // サーバと接続
        self.client.connect()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // どこかタッチしたらキーボード閉じる
        self.view.endEditing(true)
    }
    
    private func setup(view: MainView) {
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Sendした時のイベントを追加
        view.inputTextView.buttonTitle = "Send"
        view.inputTextView.button.addTarget(self, action: #selector(self.sendPush), for: .touchUpInside)
    }
    
    private func setupClient() -> Void {
        
        // channel作成
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
        
        self.client.onConnected = {
            // Connect成功時に通知する
            print("Connect!")
            let alert: UIAlertController = UIAlertController(title: "Connect Success!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        self.client.willReconnect = {
            // Connect失敗時 or Serverから切られた時に呼ばれる
            print("Disconnect")
            let alert: UIAlertController = UIAlertController(title: "Connect Fail...", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "Reconnect", style: .default, handler:{(action: UIAlertAction!) -> Void in
                // 再connect
                self.client.connect()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{(action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return true
        }
    }
    
    internal func sendPush() {
        // Sendボタンを押した時のメソッド
        let message = (self.chatView?.inputTextView.inputField.text)!
        let time = getTime()
        // message前後の不要な改行と空白削除
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // actionで送信
        if (!(prettyMessage.isEmpty)) {
            //self.channel?.action("talk", with: ["name": self.userName, "time": time, "message": prettyMessage])
            self.channel?.action(self.actionName, with: ["name": self.userName, "message": prettyMessage])
        }
        self.chatView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
    private func getTime() -> String {
        // 現在時刻取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let now = Date()
        return formatter.string(from: now)
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
