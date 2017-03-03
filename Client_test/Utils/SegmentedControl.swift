//
//  SegmentedControl.swift
//  asukabu-taiwan
//
//  Created by Atsushi Ishibashi on 11/1/16.
//  Copyright © 2016 atsushi. All rights reserved.
//

import UIKit

class SegmentedControl: UIControl {

    private var btnList: [UIButton] = []

    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(items: [String]) {
        self.init()
        setItems(items: items)
    }

    private func setItems(items: [String]) {
        for tuple in items.enumerated() {
            let btn: UIButton = UIButton()
            btn.setTitle(tuple.element, for: .normal)
            btn.setTitle(tuple.element, for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitleColor(Color.String.black, for: .normal)
            btn.setTitleColor(UIColor.white, for: .selected)
            btn.backgroundColor = Color.gray
            btn.tag = tuple.offset
            btn.addTarget(self, action: #selector(selectedBtn(sender:)), for: .touchUpInside)
            addSubview(btn)
            btnList += [btn]
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let rect: CGRect = bounds
        let btnWidth: CGFloat = rect.size.width / CGFloat(btnList.count)
        for tuple in btnList.enumerated() {
            tuple.element.frame = CGRect(x: btnWidth*CGFloat(tuple.offset), y: 0, width: btnWidth, height: rect.size.height)
        }
    }

    var selectedSegmentIndex: Int {
        get {
            var selectedIndex: Int = 0
            for tuple in btnList.enumerated() {
                if tuple.element.isSelected {
                    selectedIndex = tuple.offset
                }
            }
            return selectedIndex
        }
        set {
            for tuple in btnList.enumerated() {
                tuple.element.isSelected = (tuple.offset == newValue) 
                tuple.element.backgroundColor = (tuple.offset == newValue) ? Color.red : Color.gray
            }
            sendActions(for: .valueChanged)
        }
    }

    internal func selectedBtn(sender: UIButton) {
        self.selectedSegmentIndex = sender.tag
    }

}
