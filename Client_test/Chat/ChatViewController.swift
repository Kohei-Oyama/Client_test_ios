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
class ChatViewController: UIViewController {
    
    private let channelIdentifier: String = "MessageChannel"
    private let actionNameChat = "chat"
    private let actionNameEnter = "enter"
    let cellName = "ChatCell"
    var channel: Channel?
    var log: Array<ChatCellValue> = Array()
    var upLabel:UILabel?
    var leftLabel:UILabel?
    var sendType = 0
    var chatView: ChatView = {
        let chatView = ChatView(frame: CGRect.zero)
        chatView.backgroundColor = UIColor.gray
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.inputTextView.button.addTarget(self, action: #selector(ChatViewController.sendTouch(sender:)), for: .touchDown)
        chatView.inputTextView.button.addTarget(self, action: #selector(ChatViewController.sendPush), for: .touchUpInside)
        chatView.inputTextView.button.addTarget(self, action: #selector(ChatViewController.sendPush), for: .touchDragOutside)
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = .up
        swipeUp.addTarget(self, action: #selector(ChatViewController.sendUp(sender:)))
        chatView.inputTextView.button.addGestureRecognizer(swipeUp)
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = .left
        swipeLeft.addTarget(self, action: #selector(ChatViewController.sendLeft(sender:)))
        chatView.inputTextView.button.addGestureRecognizer(swipeLeft)
        chatView.inputTextView.buttonTitle = "Send"
        return chatView
    }()
    var client: ActionCableClient?
    var userName: String?
    var userID: Int?
    var roomID: Int?
    var roomName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewの設定
        chatView.tableView.delegate = self
        chatView.tableView.dataSource = self
        chatView.tableView.register(ChatCell.self, forCellReuseIdentifier: self.cellName)
        view.addSubview(chatView)
        chatView.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
    }
    
    // コントローラ起動時の初期設定
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = roomName
        // channelのstreamを変更
        let roomIdentifier = ["roomID" : self.roomID!, "userID" : self.userID!]
        self.channel = self.client?.create(self.channelIdentifier, identifier: roomIdentifier)
        self.log = []
        // 受信処理
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error as! String)
                return
            }
            let JSONObject = JSON(data!)
            let recieveArray = JSONObject.arrayValue.map{ ChatCellValue(userName: $0["userName"].stringValue, messageLog: $0["messageLog"].stringValue)}
            var obj: ChatCellValue?
            for i in 0..<recieveArray.count {
                guard let userName = recieveArray[i].userName else { continue }
                guard let messageLog = recieveArray[i].messageLog else { continue }
                obj = ChatCellValue(userName: userName, messageLog: messageLog)
                self.log.append(obj!)
                if i == (recieveArray.count - 1 ){
                    self.chatView.tableView.reloadData()
                }
            }
            // 自分が発言したら or Enterしたとき一番下にスクロール
            if (obj?.userName! == self.userName) || recieveArray.count > 1 {
                let indexPath = IndexPath(row: self.log.count - 1, section: 0)
                self.chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        self.channel?.action(self.actionNameEnter, with: ["roomID": self.roomID!, "userID": self.userID!])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.channel?.unsubscribe()
    }
    
    //ボタンに触れた時のアクション
    func sendTouch(sender: UIButton){
        if upLabel == nil{
            upLabel = UILabel()
            upLabel!.frame = CGRect(x: 0, y: 0, width: sender.frame.width, height: sender.frame.height)
            //起点となるボタンを支点とする
            upLabel!.layer.position = CGPoint(x:sender.layer.position.x, y:sender.layer.position.y - sender.frame.height)
            upLabel!.backgroundColor = UIColor.red
            upLabel!.text = "red"
            upLabel!.font = UIFont.systemFont(ofSize: 10)
            upLabel!.textAlignment = NSTextAlignment.center
            self.chatView.inputTextView.addSubview(upLabel!)
        }
        if leftLabel == nil{
            leftLabel = UILabel()
            leftLabel!.frame = CGRect(x: 0, y: 0, width: sender.frame.width, height: sender.frame.height)
            leftLabel!.layer.position = CGPoint(x:sender.layer.position.x - sender.frame.width, y:sender.layer.position.y)
            leftLabel!.backgroundColor = UIColor.blue
            leftLabel!.text = "blue"
            leftLabel!.font = UIFont.systemFont(ofSize: 10)
            leftLabel!.textAlignment = NSTextAlignment.center
            self.chatView.inputTextView.addSubview(leftLabel!)
        }
    }
    
    //上にスワイプした時
    func sendUp(sender:UISwipeGestureRecognizer){
        print("UP")
        self.sendType = 1
        sendPush()
    }
    //下にスワイプした時
    func sendLeft(sender:UISwipeGestureRecognizer){
        print("Left")
        self.sendType = 2
        sendPush()
    }
    
    // Send
    func sendPush() {
        print(self.sendType)
        if self.upLabel != nil && self.leftLabel != nil {
            self.upLabel!.removeFromSuperview()
            self.leftLabel!.removeFromSuperview()
            self.upLabel = nil
            self.leftLabel = nil
        }
        let message = (self.chatView.inputTextView.inputField.text)!
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyMessage.isEmpty)) {
            self.channel?.action(self.actionNameChat, with: ["userID": self.userID!, "messageLog": prettyMessage, "roomID": self.roomID!])
        }
        self.chatView.inputTextView.inputField.text = ""
        view.endEditing(true)
        self.sendType = 0
    }
}

// UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    // Cellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.log.count {
            let object = self.log[indexPath.row]
            let messageLabel = PaddingLabel(frame: CGRect.zero)
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            messageLabel.font = UIFont.boldSystemFont(ofSize: ChatCell.messageFontSize)
            guard let message = object.messageLog else { return 0 }
            messageLabel.text = message
            let maxWidth = self.view.frame.width - 2.0 * (ChatCell.inset + PaddingLabel.paddingSize)
            let messageLabelFrame = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            let messageLabelRect = messageLabel.sizeThatFits(messageLabelFrame)
            
            let nameLabel = UILabel(frame: CGRect.zero)
            nameLabel.numberOfLines = 1
            nameLabel.font = UIFont.boldSystemFont(ofSize: ChatCell.nameFontSize)
            nameLabel.text = object.userName!
            nameLabel.sizeToFit()
            
            // 余白混みでメッセージと名前が入りきる高さ
            return messageLabelRect.height + 2.0 * PaddingLabel.paddingSize + 3.0 * ChatCell.inset + nameLabel.frame.height
        } else { return 0 }
    }
}

// UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    // Cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.log.count
    }
    
    // Cellの中身設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellName, for: indexPath) as! ChatCell
        if indexPath.row < self.log.count {
            let msg = self.log[indexPath.row]
            cell.object = msg
            
            let maxWidth = self.view.frame.width - 2.0 * (ChatCell.inset + PaddingLabel.paddingSize)
            let frame = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            let rect = cell.messageLabel.sizeThatFits(frame)
            
            cell.backView.snp.remakeConstraints { (make) -> Void in
                make.bottom.equalTo(cell)
                make.width.equalTo(rect.width + 2.0 * (PaddingLabel.paddingSize + ChatCell.inset))
                make.top.equalTo(cell.nameLabel.snp.bottom)
            }
            
            cell.messageLabel.snp.remakeConstraints { (make) -> Void in
                make.bottom.equalTo(cell).offset(-ChatCell.inset)
                make.width.equalTo(rect.width + 2.0 * PaddingLabel.paddingSize)
            }
            cell.nameLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(cell).offset(ChatCell.inset)
                make.bottom.equalTo(cell.messageLabel.snp.top).offset(-ChatCell.inset)
            }
            
            // 自分の発言は右側に出現
            cell.backView.transform = CGAffineTransform.identity
            if msg.userName! == self.userName! {
                
                cell.backView.transform = cell.backView.transform.scaledBy(x: -1.0, y: 1.0)
                cell.backView.snp.makeConstraints { (make) -> Void in
                    make.right.equalTo(cell)
                }
                cell.messageLabel.snp.makeConstraints { (make) -> Void in
                    make.right.equalTo(cell).offset(-ChatCell.inset)
                }
                cell.nameLabel.snp.makeConstraints { (make) -> Void in
                    make.right.equalTo(cell).offset(-ChatCell.inset)
                }
            } else {
                cell.backView.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(cell)
                }
                cell.messageLabel.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(cell).offset(ChatCell.inset)
                }
                cell.nameLabel.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(cell).offset(ChatCell.inset)
                }
            }
            return cell
        } else {
            print("Chat Cell Error")
            return ChatCell()
        }
    }
}
