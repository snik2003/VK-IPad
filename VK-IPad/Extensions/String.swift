//
//  String.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

extension String {
    func groupTypeToString(profile: GroupProfile) -> String {
        
        var type = ""
        if profile.deactivated != "" {
            if profile.deactivated == "banned" {
                type = "Сообщество заблокировано"
            }
            if profile.deactivated == "deleted" {
                type = "Сообщество удалено"
            }
        } else {
            if profile.type == "group" {
                if profile.isClosed == 0 {
                    type = "Открытая группа"
                } else {
                    type = "Закрытая группа"
                }
            }
            if profile.type == "page" {
                type = "Публичная страница"
            }
            if profile.type == "event" {
                type = "Мероприятие"
            }
        }
        
        return type
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func getDateFromString() -> Date? {
        let dateStr = self
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let dateArray = dateStr.components(separatedBy: ".")
        let components = NSDateComponents()
        
        if dateArray.count > 2, let year = Int(dateArray[2]), let month =  Int(dateArray[1]), let day =  Int(dateArray[0]) {
            components.year = year
            components.month = month
            components.day = day
            components.timeZone = TimeZone(abbreviation: "GMT+0:00")
            let date = calendar?.date(from: components as DateComponents)
            
            return date
        }
        
        return nil
    }
    
    var nsString: NSString { return self as NSString }
    
    var length: Int { return nsString.length }
    
    var nsRange: NSRange { return NSRange(location: 0, length: length) }
    
    var detectDates: [Date]? {
        return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            .matches(in: self, range: nsRange)
            .compactMap{$0.date}
    }
}
