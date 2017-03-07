//
//  ViewController.swift
//  Client_test
//
//  Created by Hirano on 2017/03/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SwiftSocket
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sendText: UITextField!
    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var recieveTextView: UITextView!
    
    let host = "localhost"
    let port: Int32 = 8083
    var client: TCPClient!
    
    @IBAction func connectToServer(_ sender: Any) {
        switch client.connect(timeout: 1) {
        case .success:
            print("connect!")
            // 受信待機を別スレッドに任せる
            DispatchQueue.global(qos: .background).async {
                while true {
                    guard let receiveObject = self.receiveJSONData() else { return }
                    // UI部分の更新はメインスレッドでないといけない
                    DispatchQueue.main.async {
                        self.appendToTextField(json: receiveObject, view: self.recieveTextView)
                    }
                }
            }
        case .failure(let error):
            print(error)
        }
    }
    
    @IBAction func sendText(_ sender: Any) {
        // dictionaryをJSONデータに変換しData型で送信
        let dict = makeDictionary()
        var jsonData: Data!
        do {
            // dict -> JSON(Data型?)
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print(error)
        }
        switch client.send(data: jsonData) {
        case .success:
            let json = JSON(data: jsonData)
            if json["text"].string != nil {
                appendToTextField(json: json, view: sendTextView)
            }
        case .failure(let error):
            print(error)
        }
        /*// textField内のtextをsend
         switch client.send(string: sendText.text! ) {
         case .success:
         appendToTextField(string: sendText.text, view: sendTextView)
         case .failure(let error):
         print(error)
         }*/
    }
    
    @IBAction func endConnection(_ sender: Any) {
        client.close()
        print("End connect")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        client = TCPClient(address: host, port: port)
        
        // textFieldの通知先とプレースホルダ
        sendText.delegate = self
        sendText.placeholder = "送りたいメッセージを入力してください"
        
        // textViewを編集不可
        sendTextView.isEditable = false
        recieveTextView.isEditable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボード閉じる
        textField.resignFirstResponder()
        return true
    }
    
    func receiveData() -> String! {
        // Stringの何か受信したらstring返す
        guard let data = client.read(1024*10) else { return nil }
        let response = String(bytes: data, encoding: .utf8)
        return response
    }
    
    func receiveJSONData() -> JSON! {
        // JSONの何か受信したらstring返す
        guard let data = client.read(1024*10) else { return nil }
        // Byte array -> Data -> JSON
        let json = JSON(data: Data(bytes: data))
        if json["text"].string != nil {
            return json
        }else{
            return nil
        }
    }
    
    func appendToTextField(string: String!, view: UITextView!) {
        // TextFieldにtext追加
        guard let string = string else { return }
        print(string)
        view.text = view.text.appending("\n\(string)")
    }
    
    func appendToTextField(json: JSON, view: UITextView!) {
        // TextFieldにJSON追加
        view.text = view.text.appending("\(json["time"].string!)\n")
        view.text = view.text.appending("From \(json["person"].string!): \(json["text"].string!)\n")
    }
    
    func makeDictionary() -> [String: String?] {
        // Dictionary作成
        let time = getTimeString()
        let dict: [String: String?] = [
            "person": "Oyama",
            "time": time,
            "text": sendText.text!
        ]
        return dict
    }
    
    func getTimeString() -> String {
        //現在時刻取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let now = Date()
        return formatter.string(from: now)
    }
}
