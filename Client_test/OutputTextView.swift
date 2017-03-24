//
//  OutputTextView.swift
//  Chat_Client
//
//  Created by Hirano on 2017/03/23.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

class OutputTextView: UIView{
    // OutputView
    
    // TextViewをとconnectボタンとendconnectボタンを持つUIView
    var textView: UITextView!
    var connect: UIButton!
    var end: UIButton!
    
    required init() {
        super.init(frame: CGRect.zero)
        self.textView = UITextView(frame: CGRect.zero)
        self.connect = UIButton(frame: CGRect.zero)
        self.end = UIButton(frame: CGRect.zero)
        self.addSubview(self.textView)
        self.addSubview(self.connect)
        self.addSubview(self.end)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
