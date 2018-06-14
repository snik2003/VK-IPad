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
    
    func ageAdder() -> String {
        
        let age = self
        if (age % 10 == 1 && (age % 100 != 11)) {
            return "\(age) год"
        } else if ((age % 10 >= 2 && age % 10 < 5) && !(age % 100 >= 12 && age % 100 < 15)) {
            return "\(age) года"
        }
        
        return "\(age) лет"
    }
    
    func membersAdder() -> String {
        
        let members = self
        if (members % 10 == 1 && (members % 100 != 11)) {
            return "\(members) участник"
        } else if ((members % 10 >= 2 && members % 10 < 5) && !(members % 100 >= 12 && members % 100 < 15)) {
            return "\(members) участника"
        }
        
        return "\(members) участников"
    }
    
    func subscribersAdder() -> String {
        
        let members = self
        if (members % 10 == 1 && (members % 100 != 11)) {
            return "\(members) подписчик"
        } else if ((members % 10 >= 2 && members % 10 < 5) && !(members % 100 >= 12 && members % 100 < 15)) {
            return "\(members) подписчика"
        }
        
        return "\(members) подписчиков"
    }
    
    func rateAdder() -> String {
        
        let rate = self
        if (rate % 10 == 1 && (rate % 100 != 11)) {
            return "\(rate) голос"
        } else if ((rate % 10 >= 2 && rate % 10 < 5) && !(rate % 100 >= 12 && rate % 100 < 15)) {
            return "\(rate) голоса"
        }
        
        return "\(rate) голосов"
    }
    
    func messageAdder() -> String {
        
        let mess = self
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) сообщение"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) сообщения"
        }
        
        return "\(mess) сообщений"
    }
    
    func attachAdder() -> String {
        
        let mess = self
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) вложение"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) вложения"
        }
        
        return "\(mess) вложений"
    }
    
    func relationCodeIntoString(sex: Int) -> String {
        let code = self
        
        if code == 1 {
            if sex == 1 {
                return "не замужем"
            } else {
                return "не женат"
            }
        }
        if code == 2 {
            if sex == 1 {
                return "есть друг"
            } else {
                return "есть подруга"
            }
        }
        if code == 3 {
            if sex == 1 {
                return "помолвлена"
            } else {
                return "помолвлен"
            }
        }
        if code == 4 {
            if sex == 1 {
                return "замужем"
            } else {
                return "женат"
            }
        }
        if code == 5 {
            return "всё сложно"
        }
        if code == 6 {
            return "в активном поиске"
        }
        if code == 7 {
            if sex == 1 {
                return "влюблена"
            } else {
                return "влюблен"
            }
        }
        if code == 8 {
            return "в гражданском браке"
        }
        
        return ""
    }
    
    func politicalToString() -> String {
        let code = self
        
        switch code {
        case 1:
            return "коммунистические"
        case 2:
            return "социалистические"
        case 3:
            return "умеренные"
        case 4:
            return "либеральные"
        case 5:
            return "консервативные"
        case 6:
            return "монархические"
        case 7:
            return "ультраконсервативные"
        case 8:
            return "индифферентные"
        case 9:
            return "либертарианские"
        default:
            return ""
        }
    }
    
    func peopleMainToString() -> String {
        let code = self
        
        switch code {
        case 1:
            return "ум и креативность"
        case 2:
            return "доброта и честность"
        case 3:
            return "красота и здоровье"
        case 4:
            return "власть и богатство"
        case 5:
            return "смелость и упорство"
        case 6:
            return "юмор и жизнелюбие"
        default:
            return ""
        }
    }
    
    func lifeMainToString() -> String {
        let code = self
        
        switch code {
        case 1:
            return "семья и дети"
        case 2:
            return "карьера и деньги"
        case 3:
            return "развлечения и отдых"
        case 4:
            return "наука и исследования"
        case 5:
            return "совершенствование мира"
        case 6:
            return "саморазвитие"
        case 7:
            return "красота и искусство"
        case 8:
            return "слава и влияние"
        default:
            return ""
        }
    }
    
    func smokingToString() -> String {
        let code = self
        
        switch code {
        case 1:
            return "резко негативное"
        case 2:
            return "негативное"
        case 3:
            return "компромиссное"
        case 4:
            return "нейтральное"
        case 5:
            return "положительное"
        default:
            return ""
        }
    }
    
    func getCounterToString() -> String {
        let num = self
        var str = "\(num)"
        
        if num >= 10000 {
            str = "10K"
        } else {
            if num > 1000 {
                let num1 = lround(Double(num) / 100)
                str = "\(Double(num1) / 10)K"
            }
        }
        
        return str
    }
}

