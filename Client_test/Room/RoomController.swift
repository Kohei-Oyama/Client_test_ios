//
//  RoomController.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import ActionCableClient
import SnapKit
import SwiftyJSON

// ルームのViewコントローラ
class RoomViewController: UIViewController {
    
    private let channelIdentifier: String = "RoomChannel"
    private let registerChannelIdentifier: String = "RegisterChannel"
    private let actionRegister = "register"
    private let actionInit = "init"
    private let actionCreate = "create"
    let actionDelete = "delete"
    let cellName = "RoomCell"
    var channel: Channel?
    private var registerChannel: Channel?
    var rooms: Array<RoomCellValue> = Array()

    var roomView : RoomView = {
        let roomView = RoomView(frame: CGRect.zero)
        roomView.backgroundColor = UIColor.gray
        roomView.translatesAutoresizingMaskIntoConstraints = false
        roomView.inputTextView.buttonTitle = "Create"
        roomView.inputTextView.button.addTarget(self, action: #selector(RoomViewController.createPush), for: .touchUpInside)
        return roomView
    }()
    
    private let client = ActionCableClient(url: myURL.Local.url)
    var userName: String?
    var userID: Int?
    let chatController: ChatViewController = ChatViewController()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Start program")
        
        // タイトル
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.title = "Rooms"
        
        // viewの設定
        roomView.tableView.delegate = self
        roomView.tableView.dataSource = self
        roomView.tableView.register(RoomCell.self, forCellReuseIdentifier: self.cellName)
        view.addSubview(roomView)
        roomView.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        roomView.tableView.addSubview(refreshControl)
                        
        // 通知
        self.client.onConnected = {
            print("Connect!")
            let alert: UIAlertController = UIAlertController(title: "Connect Success!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) -> Void in
                self.rooms = []
                self.channel?.action(self.actionInit)
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        self.client.onDisconnected = {(error: Error?) in
            print("Disconnect")
        }
        
        self.client.willReconnect = {
            print("Reconnect")
            let alert: UIAlertController = UIAlertController(title: "Connect Fail...", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "Reconnect", style: .default, handler:{(action: UIAlertAction!) -> Void in
                self.client.connect()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return true
        }
        
        self.chatController.client = self.client
        
        self.client.connect()
        
        // アプリの初回起動でユーザ登録
        let userName = UserDefaults.standard
        let userNameValue = ["userName": ""]
        userName.register(defaults: userNameValue)
        
        let userID = UserDefaults.standard
        let userIDValue = ["userID": 0]
        userID.register(defaults: userIDValue)
        
        let userDefault = UserDefaults.standard
        let dict = ["firstLaunch": true]
        userDefault.register(defaults: dict)
        if userDefault.bool(forKey: "firstLaunch") {
            userDefault.set(false, forKey: "firstLaunch")
            self.registerUser(name: userName, ID: userID)
        }
        self.userName = userName.string(forKey: "userName")
        self.userID = userID.integer(forKey: "userID")
        
        // channel作成
        self.channel = client.create(self.channelIdentifier, identifier: ["userID": self.userID!])
        // 受信設定
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error as! String)
                return
            }
            let JSONObject = JSON(data!)
            var recieveArray = JSONObject.arrayValue.map{ RoomCellValue(roomName: $0["roomName"].stringValue, roomID: $0["id"].intValue, time: $0["time"].stringValue)}
            print(recieveArray)
            for i in 0..<recieveArray.count {
                guard let time = recieveArray[i].time else { continue }
                guard let roomName = recieveArray[i].roomName else { continue }
                let roomID = recieveArray[i].roomID
                let createTime = DateUtils.dateFromString(string: time, format: "yyyy/MM/dd HH:mm:ss Z")
                let now = Date()
                let duration = now.offsetFrom(date: createTime)
                let obj = RoomCellValue(roomName: roomName, roomID: roomID, time: duration)
                
                self.rooms.insert(obj, at: 0)
            }
            self.roomView.tableView.reloadData()
        }
    }
    
    // ユーザ登録のQue送る
    private func registerUser(name: UserDefaults, ID: UserDefaults) {
        let alert = UIAlertController(title: "Setting Name", message: "What's Your Name?", preferredStyle: UIAlertControllerStyle.alert)
        var nameTextField: UITextField?
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Your Name"
            nameTextField = textField
        })
        alert.addAction(UIAlertAction(title: "Register", style: .default, handler: {action in
            let registerName = (nameTextField?.text)!
            let registerID = registerName + DateUtils.stringFromDate(date: Date(), format: "yyyy/MM-dd HH:mm:ss Z")
            let registerIdentifier = ["registerID" : registerID]
            self.registerChannel = (self.client.create(self.registerChannelIdentifier, identifier: registerIdentifier, autoSubscribe: false, bufferActions: true))
            self.registerChannel?.subscribe()
            // 受信設定
            self.registerChannel?.onReceive = {(data: Any?, error: Error?) in
                if let _ = error {
                    print(error as! String)
                    return
                }
                let JSONObject = JSON(data!)
                name.set(registerName, forKey: "userName")
                ID.set(JSONObject["userID"].int, forKey: "userID")
                self.userName = name.string(forKey: "userName")
                self.userID = ID.integer(forKey: "userID")
                self.registerChannel?.unsubscribe()
            }
            self.registerChannel?.action(self.actionRegister, with: ["userName": registerName])
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Room画面になる度に一覧リセット
        self.rooms = []
        self.channel?.action(self.actionInit)
    }
    
    // Create
    func createPush() {
        let name = (self.roomView.inputTextView.inputField.text)!
        let time = DateUtils.stringFromDate(date: Date(), format: "yyyy/MM-dd HH:mm:ss Z")
        let prettyName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyName.isEmpty)) {
            self.channel?.action(self.actionCreate, with: ["roomName": prettyName, "time": time])
        }
        self.roomView.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
    // tableの更新
    func refresh() {
        self.rooms = []
        self.channel?.action(self.actionInit)
        refreshControl.endRefreshing()
    }
}

// UITableViewDelegate
extension RoomViewController: UITableViewDelegate {
    
    // Cellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = self.rooms[indexPath.row]
        let attrString = object.attributedString(sentence: object.roomName!, fontSize: 18.0)
        let width = self.roomView.tableView.bounds.size.width;
        let rect = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        
        // messageのサイズ + Labelの上下の余白 + Label中のtextの余白 + 1
        return rect.size.height + (RoomCell.inset * 2.0) + 16 + 1
    }
    
    // Cellタップで画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let room = self.rooms[indexPath.row]
        self.chatController.roomID = room.roomID
        self.chatController.userID = self.userID!
        self.chatController.userName = self.userName!
        self.chatController.roomName = room.roomName!
        self.navigationController?.pushViewController(self.chatController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Cellの削除
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            let alert: UIAlertController = UIAlertController(title: "本当に削除しますか？", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) -> Void in
                let room = self.rooms[indexPath.row]
                self.rooms.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.channel?.action(self.actionDelete, with: ["roomID": room.roomID])
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        deleteButton.backgroundColor = UIColor.red
        return [deleteButton]
    }
}

// UITableViewDataSource
extension RoomViewController: UITableViewDataSource {
    // Cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    // Cellの中身設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellName, for: indexPath) as! RoomCell
        cell.cellValue = rooms[indexPath.row]
        cell.nameLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(cell).offset(RoomCell.inset)
            make.bottom.equalTo(cell).offset(-RoomCell.inset)
        }
        cell.timeLabel.snp.remakeConstraints { (make) -> Void in
            make.right.equalTo(cell).offset(-RoomCell.inset)
            make.bottom.equalTo(cell).offset(-RoomCell.inset)
        }
        return cell
    }
}
