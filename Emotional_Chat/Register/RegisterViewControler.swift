//
//  RegisterControler.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/19.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import ActionCableClient
import SwiftyJSON

// 登録画面のViewコントローラ
class RegisterViewController: UIViewController {
    
    private let registerChannelIdentifier: String = "RegisterChannel"
    private let actionRegister = "register"
    private let client = ActionCableClient(url: myURL.Deploy.url)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        // 通知
        self.client.onConnected = {
            print("Connect!")
            let alert: UIAlertController = UIAlertController(title: "Connect Success!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) -> Void in
                
                // アプリの初回起動でユーザ登録
                let userName = UserDefaults.standard
                userName.register(defaults: ["userName": ""])
                let userID = UserDefaults.standard
                userID.register(defaults: ["userID": 0])
                let userDefault = UserDefaults.standard
                userDefault.register(defaults: ["firstLaunch": true])
                
                if userDefault.bool(forKey: "firstLaunch") {
                    userDefault.set(false, forKey: "firstLaunch")
                    self.registerUser(name: userName, ID: userID)
                } else {
                    self.changeToRoomsView(name: userName.string(forKey: "userName")!, ID: userID.integer(forKey: "userID"))
                }
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        self.client.connect()
    }
    
    // ユーザ登録
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
            let registerChannel = self.client.create(self.registerChannelIdentifier, identifier: registerIdentifier)
            // 受信設定
            registerChannel.onReceive = {(data: Any?, error: Error?) in
                if let _ = error {
                    print(error as! String)
                    return
                }
                let JSONObject = JSON(data!)
                name.set(registerName, forKey: "userName")
                ID.set(JSONObject["userID"].int, forKey: "userID")
                registerChannel.unsubscribe()
                self.changeToRoomsView(name: registerName, ID: JSONObject["userID"].int!)
            }
            registerChannel.action(self.actionRegister, with: ["userName" : registerName])
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // RoomViewへの遷移
    private func changeToRoomsView(name: String, ID: Int) {
        let roomController = RoomViewController()
        roomController.client = self.client
        roomController.userName = name
        roomController.userID = ID
        self.navigationController?.pushViewController(roomController, animated: false)
    }
}
