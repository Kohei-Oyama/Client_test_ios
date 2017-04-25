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
        guard let years = yearsFrom(date: date) else { return "Error Date" }
        if years > 0 { return "\(years)年前" }
        guard let months = monthsFrom(date: date) else { return "Error Date" }
        if months > 0 { return "\(months)ヶ月前" }
        guard let weeks = weeksFrom(date: date) else { return "Error Date" }
        if weeks > 0 { return "\(weeks)週間前" }
        guard let days = daysFrom(date: date) else { return "Error Date" }
        if days > 0 { return "\(days)日前" }
        guard let hours = hoursFrom(date: date) else { return "Error Date" }
        if hours > 0 { return "\(hours)時間前" }
        guard let minutes = minutesFrom(date: date) else { return "Error Date" }
        if minutes > 0 { return "\(minutes)分前" }
        guard let seconds = secondsFrom(date: date) else { return "Error Date" }
        if seconds > 0 { return "\(seconds)秒前" }
        return "たった今"
    }
    
    func yearsFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: date, to: self).year
    }
    func monthsFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: date, to: self).month
    }
    func weeksFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear
    }
    func daysFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: date, to: self).day
    }
    func hoursFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour
    }
    func minutesFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute
    }
    func secondsFrom(date: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: date, to: self).second
    }
}
