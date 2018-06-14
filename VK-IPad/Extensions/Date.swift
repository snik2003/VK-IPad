//
//  Date.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

extension Date {
    var age: Int {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        let curDay = components.day!
        let curMonth = components.month!
        let curYear = components.year!
        
        components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let day = curDay - components.day!
        let month = curMonth - components.month!
        let year = curYear - components.year!
        
        if month < 0 {
            return year - 1
        } else if month == 0 {
            if day < 0 {
                return year - 1
            } else {
                return year
            }
        } else {
            return year
        }
    }
}
