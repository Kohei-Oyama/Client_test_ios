//
//  ViewController.swift
//  Client_test
//
//  Created by Hirano on 2017/03/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sendText: UITextField!
    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var recieveTextView: UITextView!
    
    let host = "localhost"
    let port: Int32 = 8084
    var client: TCPClient!
    
    @IBAction func connectToServer(_ sender: Any) {
        switch client.connect(timeout: 1) {
        case .success:
            print("connect!")
            // 受信待機を別スレッドに任せる
            DispatchQueue.global(qos: .background).async {
                while true {
                    guard let recieveText = self.receiveData() else { return }
                    // UI部分の更新はメインスレッドでないといけない
                    DispatchQueue.main.async {
                        self.appendToTextField(string: recieveText, view: self.recieveTextView)
                    }
                }
            }
        case .failure(let error):
            print(error)
        }
    }
    
    @IBAction func sendText(_ sender: Any) {
        //textField内のtextをsend
        switch client.send(string: sendText.text! ) {
        case .success:
            appendToTextField(string: sendText.text, view: sendTextView)
        case .failure(let error):
            print(error)
        }
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
        // 何か受信したらstring返す
        guard let data = client.read(1024*10) else { return nil }
        let response = String(bytes: data, encoding: .utf8)
        return response
    }
    
    func appendToTextField(string: String!, view: UITextView!) {
        // TextFieldにtext追加
        guard let string = string else { return }
        print(string)
        view.text = view.text.appending("\n\(string)")
    }
}
