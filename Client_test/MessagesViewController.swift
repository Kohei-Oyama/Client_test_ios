//
//  MessagesViewController.swift
//  Client_test
//
//  Created by Hirano on 2017/03/12.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import SwiftyJSON
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    
    private var messages: [JSQMessage] = []
    private var incomingBubble: JSQMessagesBubbleImage!
    private var outgoingBubble: JSQMessagesBubbleImage!
    private var incomingAvatar: JSQMessagesAvatarImage!
    
    // テスト用
    private let targetUser: JSON = ["senderId": "targetUser", "displayName": "passion"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSettings()
    }
    
    private func initialSettings() {
        // 自分の情報入力
        self.senderId = "self"
        self.senderDisplayName = "自分の名前"
        // 吹き出しの色設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        // 相手の画像設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "sample_user")!, diameter: 64)
        // 自分の画像を表示しない
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    // 送信ボタンを押した時の挙動
    /*override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message)
        // 更新
        finishSendingMessageAnimated(true)
        
        sendAutoMessage()
    }*/
    
    // 表示するメッセージの内容
    func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    // 表示するメッセージの背景を指定
    func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.item].senderId == senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // 表示するユーザーアイコンを指定。nilを指定すると画像がでない
    func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        if messages[indexPath.item].senderId != self.senderId {
            return incomingAvatar
        }
        return nil
    }
    
    // メッセージの件数を指定
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // テストでメッセージを送信するためのメソッド
    /*private func sendAutoMessage() {
        let message = JSQMessage(senderId: targetUser["senderId"].string, displayName: targetUser["displayName"].string, text: "返信するぞ")
        messages.append(message)
        finishReceivingMessageAnimated(true)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 送信時刻を出すために高さを調整する
    /*override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if message.date.timeIntervalSinceDate(previousMessage.date) / 60 > 1 {
                return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
            }
        }
        return nil
    }
    
    // 送信時刻を出すために高さを調整する
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            let message = messages[indexPath.item]
            if message.date .timeIntervalSinceDate(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        // ユーザーアイコンに対してジェスチャーをつける
        let avatarImageTap = UITapGestureRecognizer(target: self, action: "tappedAvatar")
        cell.avatarImageView?.userInteractionEnabled = true
        cell.avatarImageView?.addGestureRecognizer(avatarImageTap)
        
        　　　　// 文字色を変える
        if messages[indexPath.item].senderId != senderId {
            cell.textView?.textColor = UIColor.darkGrayColor()
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tappedAvatar() {
        print("tapped user avatar")
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        selectImage()
    }
    private func selectImage() {
        let alertController = UIAlertController(title: "画像を選択", message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "カメラを起動", style: .Default) { (UIAlertAction) -> Void in
            self.selectFromCamera()
        }
        let libraryAction = UIAlertAction(title: "カメラロールから選択", style: .Default) { (UIAlertAction) -> Void in
            self.selectFromLibrary()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { (UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
    }
    
    private func selectFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerController.allowsEditing = true
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラ許可をしていない時の処理")
        }
    }
    
    private func selectFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerController.allowsEditing = true
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラロール許可をしていない時の処理")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] {
            sendImageMessage(image)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    private func sendImageMessage(image: UIImage) {
        let photoItem = JSQPhotoMediaItem(image: image)
        let imageMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photoItem)
        messages.append(imageMessage)
        finishSendingMessageAnimated(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        if messages[indexPath.item].isMediaMessage {
            let media = messages[indexPath.item].media
            if media .isKindOfClass(JSQPhotoMediaItem) {
                print("tapped Image")
            }
        }
    }*/
}
