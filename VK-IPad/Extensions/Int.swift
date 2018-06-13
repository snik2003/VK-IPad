//
//  Int.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

extension Int {
    func toStringLastTime() -> String {
        
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
            dateFormatter.dateFormat = "dd MMMM yyyyг. в HH:mm"
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter
        }()
        
        var str = ""
        
        if self <= Int(NSDate().timeIntervalSince1970) {
            let interval = Int(NSDate().timeIntervalSince1970) - self
            
            if interval < 60 {
                str = "только что"
            }
            
            if interval >= 60 && interval < 3600 {
                let min = interval / 60
                
                if min % 10 == 1 {
                    str = "\(min) минуту назад"
                }
                
                if min > 10 && min < 20 {
                    if min % 10 >= 1 && min % 10 <= 9 {
                        str = "\(min) минут назад"
                    }
                } else {
                    if min % 10 > 1 && min % 10 < 5 {
                        str = "\(min) минуты назад"
                    }
                    
                }
                
                if min % 10 >= 5 || min % 10 == 0 {
                    str = "\(min) минут назад"
                }
            }
            
            if interval >= 3600 && interval <= 18000 {
                let hour = interval / 3600
                
                if hour == 1 {
                    str = "час назад"
                }
                if hour == 2 {
                    str = "два часа назад"
                }
                if hour == 3 {
                    str = "три часа назад"
                }
                if hour == 4 {
                    str = "четыре часа назад"
                }
                if hour == 5 {
                    str = "пять часов назад"
                }
                
            }
            
            if interval > 18000 {
                let date = NSDate(timeIntervalSince1970: Double(self))
                str = dateFormatter.string(from: date as Date)
            }
        } else {
            let date = NSDate(timeIntervalSince1970: Double(self))
            str = dateFormatter.string(from: date as Date)
        }
        
        return str
    }
    
    func toStringCommentLastTime() -> String {
        
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
            dateFormatter.dateFormat = "dd.MM.yyyy в HH:mm"
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter
        }()
        
        var str = ""
        
        if self <= Int(NSDate().timeIntervalSince1970) {
            let interval = Int(NSDate().timeIntervalSince1970) - self
            
            if interval < 60 {
                str = "только что"
            }
            
            if interval >= 60 && interval < 3600 {
                let min = interval / 60
                
                if min % 10 == 1 {
                    str = "\(min) минуту назад"
                }
                
                if min > 10 && min < 20 {
                    if min % 10 >= 1 && min % 10 <= 9 {
                        str = "\(min) минут назад"
                    }
                } else {
                    if min % 10 > 1 && min % 10 < 5 {
                        str = "\(min) минуты назад"
                    }
                    
                }
                
                if min % 10 >= 5 || min % 10 == 0 {
                    str = "\(min) минут назад"
                }
            }
            
            if interval >= 3600 && interval <= 18000 {
                let hour = interval / 3600
                
                if hour == 1 {
                    str = "час назад"
                }
                if hour == 2 {
                    str = "два часа назад"
                }
                if hour == 3 {
                    str = "три часа назад"
                }
                if hour == 4 {
                    str = "четыре часа назад"
                }
                if hour == 5 {
                    str = "пять часов назад"
                }
                
            }
            
            if interval > 18000 {
                let date = NSDate(timeIntervalSince1970: Double(self))
                str = dateFormatter.string(from: date as Date)
            }
        } else {
            let date = NSDate(timeIntervalSince1970: Double(self))
            str = dateFormatter.string(from: date as Date)
        }
        
        return str
    }
}

