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
    
    var userName: String = ""
    var rooms: Array<RoomObject> = Array()
    var roomView: RoomView?
    let cellName = "RoomCell"
    let nextVC: MainViewController = MainViewController()
    internal var channelIdentifier: String = "RoomChannel"
    private let actionCreate = "create"
    private let actionInit = "init"
    let client = ActionCableClient(url: URL(string:"ws://localhost:3000/cable")!)
    //let client = ActionCableClient(url: URL(string:"ws://192.168.11.5:3000/cable")!)
    //let client = ActionCableClient(url: URL(string:"ws://10.213.225.68:3000/cable")!)
    //let client = ActionCableClient(url: URL(string:"wss://actioncable-echo.herokuapp.com/cable")!)
    
    private var channel: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewの設定
        roomView = RoomView(frame: view.bounds)
        roomView?.backgroundColor = UIColor.gray
        roomView?.translatesAutoresizingMaskIntoConstraints = false
        roomView?.inputTextView.buttonTitle = "Create"
        roomView?.inputTextView.button.addTarget(self, action: #selector(self.createPush), for: .touchUpInside)
        roomView?.tableView.delegate = self
        roomView?.tableView.dataSource = self
        roomView?.tableView.allowsSelection = true
        roomView?.tableView.register(RoomCell.self, forCellReuseIdentifier: self.cellName)

        view.addSubview(roomView!)
        roomView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        
        // タイトル
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.title = "Rooms"
        
        setupChannel()
    }
    
    // コントローラ起動時にユーザ名決まってなかったら登録
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.userName == "" {
            let alert = UIAlertController(title: "Setting Name", message: "What's Your Name?", preferredStyle: UIAlertControllerStyle.alert)
            var nameTextField: UITextField?
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Your Name"
                nameTextField = textField
            })
            alert.addAction(UIAlertAction(title: "Start", style: .default, handler: {action in
                self.userName = (nameTextField?.text)!
                // サーバと接続
                self.client.connect()
                // Room名一覧を取得するQueを送る
                self.channel?.action(self.actionInit, with: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupChannel() -> Void {
        // channel作成
        self.channel = client.create(self.channelIdentifier)
        // Room一覧を受信?
        self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error)
                return
            }
            
            let JSONObject = JSON(data!)
            let obj = RoomObject(name: JSONObject["roomName"].string!, time: JSONObject["time"].string!)
            self.rooms.append(obj)
            self.roomView?.tableView.reloadData()
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

    // どこかタッチしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Createボタンを押した時のメソッド
    func createPush() {
        let name = (self.roomView?.inputTextView.inputField.text)!
        let time = getTime()
        let prettyName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyName.isEmpty)) {
            let obj = RoomObject(name: prettyName, time: time)
            self.channel?.action(self.actionCreate, with: ["roomName": name, "time": time])
            self.rooms.append(obj)
            self.roomView?.tableView.reloadData()
        }
        self.roomView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
    // 現在時刻取得
    private func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd' 'HH:mm"
        let now = Date()
        return formatter.string(from: now)
    }
}

// UITableViewDelegate
extension RoomViewController: UITableViewDelegate {
    
    // RoomCellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = rooms[(indexPath as NSIndexPath).row]
        let attrString = object.nameAttributedString()
        let width = self.roomView?.tableView.bounds.size.width;
        // message(1行)が入るサイズ
        let rect = attrString.boundingRect(with: CGSize(width: width!, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context:nil)
        
        // messageのサイズ + Labelの上下の余白 + Label中のtextの余白 + 1
        return rect.size.height + (RoomCell.inset * 2.0) + 16 + 1
    }
    
    // Cellタップされたら画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let room = rooms[(indexPath as NSIndexPath).row]
        // ユーザ名とルーム名とClientを渡す
        self.nextVC.userName = self.userName
        self.nextVC.client = self.client
        self.nextVC.roomName = room.name
        self.nextVC.setupChannel()
        self.navigationController?.pushViewController(nextVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
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
        let object = rooms[(indexPath as NSIndexPath).row]
        cell.object = object
        
        // Cellの制約
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
