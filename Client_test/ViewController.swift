//
//  ViewController.swift
//  Client_test
//
//  Created by Hirano on 2017/03/02.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController ,UITextFieldDelegate {
    
    var socket = SocketIOClient(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .forcePolling(true)])
    
    @IBOutlet weak var SendObject: UITextField!
    @IBOutlet weak var RecieveObject: UITextField!
    
    @IBAction func BT_Connect(_ sender: Any) {
        self.socket.connect()
    }
    
    @IBAction func BT_Send(_ sender: Any) {
        //box内のMessageをsendする(オプショナルバインド)
        self.socket.emit("HelloWorld")
    }
    
    @IBAction func BT_End(_ sender: Any) {
        self.socket.disconnect()
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
    
//    class Connection : NSObject, StreamDelegate {
//        let serverAddress: String = "192.168.0.7"
//        let serverPort : UInt32 = 8002
//        
//        private var inputStream: InputStream!
//        private var outputStream: OutputStream!
//        
//        func connect() {
//            print("connecrting...")
//            
//            var readStream: Unmanaged<CFReadStream>?
//            var writeStream: Unmanaged<CFWriteStream>?
//            
//            CFStreamCreatePairWithSocketToHost(nil, self.serverAddress as CFString!, self.serverPort, &readStream, &writeStream)
//            
//            self.inputStream = readStream!.takeRetainedValue()
//            self.outputStream = writeStream!.takeRetainedValue()
//            
//            self.inputStream.delegate = self
//            self.outputStream.delegate = self
//            
//            self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
//            self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
//            
//            self.inputStream.open()
//            self.outputStream.open()
//            
//            print("connent success!!")
//            
//        }
//        
//                func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
//                }
//        
//        func sendCommand(_ command: String){
//            //String to UTF-8
//            //Date型はbyteプロパティを持たない(NSDataはもつ)
//            var ccomand = command.data(using: String.Encoding.utf8)!
//            self.outputStream!.write(ccomand.first, maxLength: ccomand.count)
//            print("Send: \(command)")
//            
//        }
//    }
}

