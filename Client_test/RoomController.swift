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
    var rooms: Array<Object> = Array()
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
        let message = (self.roomView?.inputTextView.inputField.text)!
        // message前後の不要な改行と空白削除
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(prettyMessage.isEmpty)) {
            let msg = Object(name: self.userName, message: prettyMessage)
            self.rooms.append(msg)
            self.roomView?.tableView.reloadData()
        }
        self.roomView?.inputTextView.inputField.text = ""
        view.endEditing(true)
    }
}

// UITableViewDelegate
extension RoomViewController: UITableViewDelegate {
    
    // RoomCellの高さ指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = rooms[(indexPath as NSIndexPath).row]
        let attrString = object.attributedString()
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
        nextVC.channelIdentifier = room.message
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
        let msg = rooms[(indexPath as NSIndexPath).row]
        cell.object = msg
        
        cell.roomLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(cell).offset(MyCell.inset)
            make.bottom.equalTo(cell).offset(-MyCell.inset)
        }
        return cell
    }
}
