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
    private let actionInit = "init"
    private let actionCreate = "create"
    let actionDelete = "delete"
    let cellName = "RoomCell"
    var channel: Channel?
    var rooms: Array<RoomCellValue> = Array()
    
    var roomView : RoomView = {
        let roomView = RoomView(frame: CGRect.zero)
        roomView.backgroundColor = UIColor.gray
        roomView.translatesAutoresizingMaskIntoConstraints = false
        roomView.inputTextView.button.addTarget(self, action: #selector(RoomViewController.createPush), for: .touchUpInside)
        roomView.inputTextView.buttonTitle = "Create"
        return roomView
    }()
    
    var client: ActionCableClient?
    var userName: String?
    var userID: Int?
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タイトル
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.navigationItem.setHidesBackButton(true, animated: false)
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
        
        // channel作成
        self.channel = self.client?.create(self.channelIdentifier, identifier: ["userID": self.userID!])
        // 受信設定
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error as! String)
                return
            }
            let JSONObject = JSON(data!)
            var recieveArray = JSONObject.arrayValue.map{ RoomCellValue(roomName: $0["roomName"].stringValue, roomID: $0["roomID"].intValue, time: $0["time"].stringValue)}
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

    // Room画面になる度に一覧リセット
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let room = self.rooms[indexPath.row]
        let chatController = ChatViewController()
        chatController.client = self.client
        chatController.userID = self.userID!
        chatController.userName = self.userName!
        chatController.roomID = room.roomID
        chatController.roomName = room.roomName!
        self.navigationController?.pushViewController(chatController, animated: true)
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
