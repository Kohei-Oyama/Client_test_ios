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
    var time: String!
    var text: String!
    
    init (person: String){
        self.person = person
    }
    
    func getTimeString(){
        // 現在時刻取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let now = Date()
        self.time = formatter.string(from: now)
    }
    
    func makeDictionary(text: String?) -> [String: String?]{
        // 辞書データ作成
        self.getTimeString()
        self.text = text
        let dict: [String: String?] = [
            "person": person,
            "time": self.time,
            "text": self.text
        ]
        return dict
    }
    
    func makeJSONData(text: String) -> Data!{
        // 辞書データからJSONのデータ型作成
        let dict = self.makeDictionary(text: text)
        do {
            // dict -> JSON(Data型?)
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            return jsonData
        } catch {
            print("error in making JSON")
            print(error)
            return nil
        }
    }
}
