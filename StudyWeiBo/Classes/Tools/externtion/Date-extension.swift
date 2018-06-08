//
//  Date-extension.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/29.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

extension Date {
    
    static func createDate(dateStr: String, formatterStr: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = formatterStr
        // 如果不指定以下代码, 在真机中可能无法转换
        formatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        return formatter.date(from: dateStr)
    }
    
    func descriptionStr() -> String {
        
        /**
         刚刚(一分钟内)
         X分钟前(一小时内)
         X小时前(当天)
         
         昨天 HH:mm(昨天)
         
         MM-dd HH:mm(一年内)
         yyyy-MM-dd HH:mm(更早期)
         */
        
        var timeResult: String = ""
        
        // 1.创建时间格式化对象
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        
        // 创建一个日历类
        let currentCalendar = NSCalendar.current
        
        // 一天内
        if currentCalendar.isDateInToday(self) {
            let interval = Int(NSDate().timeIntervalSince(self))
            
            if interval < 60 {
                timeResult = "刚刚"
            }else if interval < 60*60 {
                timeResult = "\(Int(interval / 60))分钟前"
            }else if interval < 60*60*24 {
                timeResult = "\(Int(interval / (60*60)))小时前"
            }
        }
            // 昨天
        else if currentCalendar.isDateInYesterday(self) {
            formatter.dateFormat = "HH:mm"
            timeResult = "昨天" + formatter.string(from: self)
        }
            // 一年内 或 更早期
        else {
            let yearCom = currentCalendar.compare(self, to: Date(), toGranularity: Calendar.Component.year)
            
            if yearCom == ComparisonResult.orderedAscending {  // 升序:  是一年前的  yyyy-MM-dd HH:mm(更早期)
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }else if yearCom == ComparisonResult.orderedSame { // 当年的  MM-dd HH:mm(一年内)
                formatter.dateFormat = "MM-dd HH:mm"
            }
            timeResult = formatter.string(from: self)
        }
        // 可以获取年 月  日  时  分  秒
        //                    let calendarCom = currentCalendar.component(Calendar.Component.year, from: createTime)
        return timeResult
        
    }
}
