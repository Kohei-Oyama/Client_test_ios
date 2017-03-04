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
    @IBOutlet weak var RecieveObject: UITextField!
    let host = "localhost"
    let port = 8084
    var client: TCPClient?
    
    @IBAction func BT_Connect(_ sender: Any) {
        client = TCPClient(address: host, port: Int32(port))
        guard let client = client else { return }
        switch client.connect(timeout: 1) {
        case .success:
            print("connect!")
            switch client.send(string: "GET / HTTP/1.0\n\n" ) {
            case .success:
                guard let data = client.read(1024*10) else { return }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    print(response)
                }
            case .failure(let error):
                print(error)
            }
        case .failure(let error):
            print(error)
        }
    }
    
    @IBAction func BT_Send(_ sender: Any) {
        //box内のMessageをsendする(オプショナルバインド)
        guard let client = client else { return }
        switch client.send(string: "Bump" ) {
        case .success:
            guard let data = client.read(1024*10) else { return }
            
            if let response = String(bytes: data, encoding: .utf8) {
                print(response)
            }
        case .failure(let error):
            print(error)
        }
    }
    
    @IBAction func BT_End(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // textFieldの通知先
        SendObject.delegate = self
        
        // プレースホルダ
        SendObject.placeholder = "送りたいメッセージを入力してください"
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
}

