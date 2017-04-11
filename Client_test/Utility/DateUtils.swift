//
//  Date.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/11.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import Foundation
import UIKit

class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

extension Date {
    func offsetFrom(date: Date) -> String {
        if yearsFrom(date: date)   > 0 { return "\(yearsFrom(date: date))年前"   }
        if monthsFrom(date: date)  > 0 { return "\(monthsFrom(date: date))ヶ月前"  }
        if weeksFrom(date: date)   > 0 { return "\(weeksFrom(date: date))週間前"   }
        if daysFrom(date: date)    > 0 { return "\(daysFrom(date: date))日前"    }
        if hoursFrom(date: date)   > 0 { return "\(hoursFrom(date: date))時間前"   }
        if minutesFrom(date: date) > 0 { return "\(minutesFrom(date: date))分前" }
        if secondsFrom(date: date) > 0 { return "\(secondsFrom(date: date))秒前" }
        return "たった今"
    }
    
    func yearsFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    func monthsFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    func weeksFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    func daysFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    func hoursFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    func minutesFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    func secondsFrom(date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
}
