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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewの設定
        roomView = RoomView(frame: view.bounds)
        setup(view: self.roomView!)
        view.addSubview(roomView!)
        roomView?.snp.remakeConstraints({ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        })
        
        // タイトル
        self.title = "Rooms"
        
        roomView?.tableView.delegate = self
        roomView?.tableView.dataSource = self
        roomView?.tableView.allowsSelection = true
        roomView?.tableView.register(RoomCell.self, forCellReuseIdentifier: self.cellName)
    }
    
    // コントローラ起動時にユーザ名登録
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
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setup(view: RoomView) {
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        // Createした時のイベントを追加
        view.inputTextView.buttonTitle = "Create"
        view.inputTextView.button.addTarget(self, action: #selector(self.createPush), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // どこかタッチしたらキーボード閉じる
        self.view.endEditing(true)
    }
    
    func createPush() {
        // Createボタンを押した時のメソッド
        let name = (self.roomView?.inputTextView.inputField.text)!
        let time = getTime()
        // name前後の不要な改行と空白削除
        let prettyName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyName.isEmpty)) {
            let obj = RoomObject(name: prettyName, time: time)
            self.rooms.append(obj)
            self.roomView?.tableView.reloadData()
        }
        self.roomView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
    
    func getTime() -> String {
        // 現在時刻取得
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
        
        let nextVC:MainViewController = MainViewController()
        let room = rooms[(indexPath as NSIndexPath).row]
        // ユーザ名とルーム名渡す
        nextVC.userName = self.userName
        nextVC.channelIdentifier = room.name
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
