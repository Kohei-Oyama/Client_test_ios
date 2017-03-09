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
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate {
    
    let host = "192.168.12.205"
    let port: Int32 = 8083
    let userName = "Oyama"
    var client: JSONSocket!
    
    @IBOutlet weak var sendText: UITextView!
    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var receiveTextView: UITextView!
    
    /*let fileManager = FileManager()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    let fileName = "sample.caf"*/
    
    @IBAction func connectToServer(_ sender: Any) {
        switch client.connect(){
        case true:
            client.receive(view: receiveTextView)
        default:
            print("connection error")
        }
    }
    
    @IBAction func sendText(_ sender: Any) {
        client.send(text: sendText.text, view: sendTextView)
    }
    
    @IBAction func endConnection(_ sender: Any) {
        client.close()
        print("End connect")
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        //audioRecorder?.record()
    }
    @IBAction func playAudio(_ sender: Any) {
        //self.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.setupAudioRecorder()
        
        client = JSONSocket(username: userName, address: host, port: port)
        
        // textFieldの通知先
        sendText.delegate = self
        
        // viewとbutton作成
        let closeView = UIView()
        closeView.frame.size.height = 30
        closeView.backgroundColor = UIColor.gray
        let closeButton = UIButton()
        closeButton.frame = CGRect(x:0,y:0,width:70,height:30)
        closeButton.setTitle("close", for: UIControlState.normal)
        closeButton.backgroundColor = UIColor.blue
        closeButton.addTarget(self, action: #selector(self.onClick(_:)), for: .touchUpInside)
        closeView.addSubview(closeButton)
        
        //キーボードのアクセサリにビューを設定
        sendText.inputAccessoryView = closeView
        
        // textView編集不可
        sendTextView.isEditable = false
        receiveTextView.isEditable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClick(_ sender: AnyObject){
        //キーボードを閉じる
        sendText.resignFirstResponder()
    }
    
    /*func setupAudioRecorder() {
        // 再生と録音機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        let recordSetting : [String : Any] = [
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey : 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100
        ]
        do {
            try audioRecorder = AVAudioRecorder(url: self.documentFilePath(), settings: recordSetting)
        } catch {
            print("初期設定でerror")
        }
    }
    
    func play() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: documentFilePath())
        } catch {
            print("再生時にerror")
        }
        audioPlayer?.play()
    }
    
    func documentFilePath()-> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsPath)
        let cacheKey = "/Desktop/Oyama"
        let fileName = "sample.caf"
        
        // ディレクトリのパス
        let folderPath=documentsPath+cacheKey
        //　ファイルのパス
        let filePath = documentsPath+cacheKey+"/"+fileName
        
        //ディレクトリとファイルの有無を調べる
        let fileManager = FileManager.default
        let isDir : Bool = false
        let isFile = fileManager.fileExists(atPath: filePath)
        //ファイルのパスからNSURLを作成することが出来ます
        let url = URL(fileURLWithPath: filePath)
        
        //ディレクトリが存在しない場合に、ディレクトリを作成する
        if !isDir {
            do {
            try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        //ファイルが存在しない場合に、ファイルを保存する
        if isFile {
            return url
        }else{
            //responseは保存しておきたいデータ（NSData型）
            //response.writeToFile(filePath, atomically: true)
            return url
        }
    }*/
}
