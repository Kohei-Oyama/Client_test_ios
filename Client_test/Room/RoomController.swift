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

    let channelIdentifier: String = "RoomChannel"
    private let actionCreate = "create"
    private let actionInit = "init"
    let actionDelete = "delete"
    let cellName = "RoomCell"

    var channel: Channel?
    var rooms: Array<Object> = Array()
    var roomView: RoomView?
    
    let client = ActionCableClient(url: URL(string:"ws://localhost:3000/cable")!)
    //let client = ActionCableClient(url: URL(string:"ws://192.168.12.126:3000/cable")!)
    var userName: String?
    let mainController: MainViewController = MainViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // タイトル
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.title = "Rooms"

        // viewの設定
        roomView = RoomView(frame: view.bounds)
        roomView?.backgroundColor = UIColor.gray
        roomView?.translatesAutoresizingMaskIntoConstraints = false
        roomView?.inputTextView.buttonTitle = "Create"
        roomView?.inputTextView.button.addTarget(self, action: #selector(self.createPush), for: .touchUpInside)
        roomView?.tableView.delegate = self
        roomView?.tableView.dataSource = self
        roomView?.tableView.register(RoomCell.self, forCellReuseIdentifier: self.cellName)

        view.addSubview(roomView!)
        roomView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        
        setupChannel()
    }
    
    private func setupChannel() -> Void {
        // channel作成
        self.channel = client.create(self.channelIdentifier)
        self.channel = client.create(self.channelIdentifier, identifier: nil, autoSubscribe: false, bufferActions: true)
        self.channel?.subscribe()
        // 受信処理
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error as! String)
                return
            }
            let JSONObject = JSON(data!)
            let createTime = DateUtils.dateFromString(string: JSONObject["time"].string!, format: "yyyy/MM/dd HH:mm:ss Z")
            let now = Date()
            let duration = now.offsetFrom(date: createTime)
            let obj = Object(name: JSONObject["roomName"].string!, time: duration, message: nil)
            self.rooms.append(obj)
            self.roomView?.tableView.reloadData()
        }

        // 通知
        self.client.onConnected = {
            print("Connect!")
            let alert: UIAlertController = UIAlertController(title: "Connect Success!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        self.client.willReconnect = {
            print("Disconnect")
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
        
        self.mainController.client = self.client

    }
    
    // ユーザ名登録とConnect
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.userName == nil {
            let alert = UIAlertController(title: "Setting Name", message: "What's Your Name?", preferredStyle: UIAlertControllerStyle.alert)
            var nameTextField: UITextField?
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Your Name"
                nameTextField = textField
            })
            alert.addAction(UIAlertAction(title: "Start", style: .default, handler: {action in
                self.userName = (nameTextField?.text)!
                self.mainController.userName = (nameTextField?.text)!
                self.client.connect()
                self.channel?.action(self.actionInit)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // タッチしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Create
    func createPush() {
        let name = (self.roomView?.inputTextView.inputField.text)!
        let time = getTime()
        let prettyName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyName.isEmpty)) {
            self.channel?.action(self.actionCreate, with: ["roomName": prettyName, "time": time])
        }
        self.roomView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
    // 現在時刻取得
    private func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM-dd HH:mm:ss Z"
        let now = Date()
        return formatter.string(from: now)
    }
}

// UITableViewDelegate
extension RoomViewController: UITableViewDelegate {
    
    // Cellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = self.rooms[(indexPath as NSIndexPath).row]
        let attrString = object.attributedString(sentence: object.name!, fontSize: 18.0)
        let width = self.roomView?.tableView.bounds.size.width;
        let rect = attrString.boundingRect(with: CGSize(width: width!, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        
        // messageのサイズ + Labelの上下の余白 + Label中のtextの余白 + 1
        return rect.size.height + (RoomCell.inset * 2.0) + 16 + 1
    }
    
    // Cellタップで画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[(indexPath as NSIndexPath).row]
        self.mainController.roomName = room.name!
        self.navigationController?.pushViewController(self.mainController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Cellの削除
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            let room = self.rooms[(indexPath as NSIndexPath).row]
            self.rooms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.channel?.action(self.actionDelete, with: ["roomName": room.name!, "time": room.time!])
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
        cell.object = rooms[(indexPath as NSIndexPath).row]
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
