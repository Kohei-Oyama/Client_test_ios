//
//  Object.swift
//  Client_test
//
//  Created by Hirano on 2017/03/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import SwiftyJSON

class Object {
    var person: String = ""
    var time: String = ""
    var text: String!
    
    func makeJSONData(text: String) -> Data!{
        // make dict
        let dict = self.makeDictionary(text: text)
        /* Array[]型で送る場合
         let dictArray: Array<Any> = [dict]
         print("dictArray\n", dictArray)*/
        do {
            // dict{…} -> Data{…}
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            return jsonData
        } catch {
            print("Data Error!\n",error)
            return nil
        }
    }
    
    func makeDictionary(text: String) -> [String: String?]{
        // 辞書データ作成
        self.getTimeString()
        self.text = text
        let dict: [String: String?] = [
            "person": person,
            "time": time,
            "text": self.text
        ]
        return dict
    }
    
    func getTimeString(){
        // 現在時刻取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let now = Date()
        time = formatter.string(from: now)
    }
}
