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
    
    @IBOutlet weak var SendObject: UITextField!
    @IBOutlet weak var Send_Text: UITextView!
    @IBOutlet weak var Recieve_Text: UITextView!
    
    let host: String = "localhost"
    let port: Int32 = 8084
    var client: TCPClient!
    
    @IBAction func BT_Connect(_ sender: Any) {
        switch client.connect(timeout: 1) {
        case .success:
            print("connect!")
            // 受信処理を別スレッドに任せる
            DispatchQueue.global(qos: .background).async {
                while true {
                    guard let RecieveObject = self.ReceiveData() else { return }
                    // UI部分の更新はメインスレッドでないといけない
                    DispatchQueue.main.async {
                        self.appendToTextField(string: RecieveObject, view: self.Recieve_Text)
                    }
                }
            }
        case .failure(let error):
            print(error)
        }
    }
    
    @IBAction func BT_Send(_ sender: Any) {
        //box内のMessageをsend
        switch client.send(string: SendObject.text! ) {
        case .success:
            appendToTextField(string: SendObject.text, view: Send_Text)
        case .failure(let error):
            print(error)
        }
    }
    
    @IBAction func BT_End(_ sender: Any) {
        client.close()
        print("End connect")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        client = TCPClient(address: host, port: port)
        
        // textFieldの通知先とプレースホルダ
        SendObject.delegate = self
        SendObject.placeholder = "送りたいメッセージを入力してください"
        
        // textViewを編集不可
        Send_Text.isEditable = false
        Recieve_Text.isEditable = false
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
    
    func ReceiveData() -> String! {
        // 何か受信したらstring返す
        guard let data = client.read(1024*10) else { return nil }
        let response = String(bytes: data, encoding: .utf8)
        return response
    }
    
    func appendToTextField(string: String!, view: UITextView!) {
        // TextFieldにtext追加
        guard let textdata = string else { return }
        print(textdata)
        view.text = view.text.appending("\n\(textdata)")
    }
}

