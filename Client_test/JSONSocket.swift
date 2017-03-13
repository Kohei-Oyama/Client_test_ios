//
//  JSONSocket.swift
//  Client_test
//
//  Created by Hirano on 2017/03/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import SwiftSocket
import SwiftyJSON

class JSONSocket {
    
    var client: TCPClient!
    var sendText: String!
    var object: Object!
    
    init(username: String, address: String, port: Int32) {
        client = TCPClient(address: address, port: port)
        object = Object()
        object.person = username
    }
    
    func connect() -> Bool {
        // connectする
        switch client.connect(timeout: 1) {
        case .success:
            print("Connect!")
            return true
        case .failure(let error):
            print("Connect Error!\n",error)
            return false
        }
    }
    
    func send(text: String?, view: UITextView!) {
        guard let text = text else { return }
        switch text.isEmpty {
        case true:
            // 空文字は送れないようにする
            print("No Message")
        default:
            // dictionary -> Data{}
            guard let objectData = object.makeJSONData(text: text) else
            { return }
            /* textでやりとりしたい場合
             switch client.send(string: text) {
             case .success:
             appendToTextField(string: text, view: view)*/
            switch client.send(data: objectData) {
            case .success:
                let json = JSON(data: objectData)
                appendToTextField(json: json, view: view)
            case .failure(let error):
                print("Send Error!\n",error)
            }
        }
    }
    
    func receive(view: UITextView!) {
        // 別スレッドで受信待機
        DispatchQueue.global(qos: .background).async {
            while true {
                //guard let receiveObject = self.receiveData() else { return }
                guard let receiveObject = self.receiveJSONData() else { return }
                // UI部分の更新はメインスレッド
                DispatchQueue.main.async {
                    //    self.appendToTextField(string: receiveObject, view: view)
                    self.appendToTextField(json: receiveObject, view: view)
                }
            }
        }
    }
    
    func receiveData() -> String! {
        // Stringの何か受信したらstring返す
        guard let data = client.read(1024*10) else { return nil }
        print(data)
        let response = String(bytes: data, encoding: .utf8)
        return response
    }
    
    func receiveJSONData() -> JSON! {
        // JSONの何か受信したらstring返す
        guard let data = client.read(1024*10) else { return nil }
        // Byte array -> Data -> JSON
        let tmpData = Data(bytes: data)
        let json = JSON(data: tmpData)
        /*if json["text"].string!.isEmpty {
            return nil
        }else{
            return json
        }*/
        return json
    }
    
    func appendToTextField(string: String, view: UITextView!) {
        // TextFieldにtext追加
        print(string)
        view.text = view.text.appending("\(string)")
    }
    
    func appendToTextField(json: JSON, view: UITextView!) {
        // TextFieldにJSON追加
        print(json["text"])
        view.text = view.text.appending("\(json["time"].string)\n")
        view.text = view.text.appending("From \(json["person"].string): \(json["text"].string)")
    }
    
    func close() {
        client.close()
    }
}
