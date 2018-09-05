//
//  Dialog.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 24.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Dialog {
    var id = 0
    var userID = 0
    var fromID = 0
    var peerID = 0
    var date = 0
    var readState = 0
    var out = 0
    var emoji = 0
    var important = 0
    var deleted = 0
    var randomID = 0
    var title = ""
    var body = ""
    
    var attachments: [Attachment] = []
    var fwdMessages: [Dialog] = []
    
    var attachCount = 0
    
    var isSelected = false
    
    var chatID = 0
    var adminID = 0
    var action = ""
    var actionID = 0
    var actionEmail = ""
    var actionText = ""
    
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.userID = json["user_id"].intValue
        self.fromID = json["from_id"].intValue
        self.peerID = json["peer_id"].intValue
        self.date = json["date"].intValue
        self.readState = json["read_state"].intValue
        self.out = json["out"].intValue
        self.emoji = json["emoji"].intValue
        self.important = json["important"].intValue
        self.deleted = json["deleted"].intValue
        self.randomID = json["random_id"].intValue
        self.title = json["title"].stringValue
        self.body = json["body"].stringValue
        
        self.attachments = json["attachments"].compactMap({ Attachment(json: $0.1) })
        self.fwdMessages = json["fwd_messages"].compactMap({ Dialog(json: $0.1) })
        
        self.chatID = json["chat_id"].intValue
        self.adminID = json["admin_id"].intValue
        self.action = json["action"].stringValue
        self.actionID = json["action_mid"].intValue
        self.actionEmail = json["action_email"].stringValue
        self.actionText = json["action_text"].stringValue
        
        if self.fromID == 0 {
            if self.out == 0 {
                self.fromID = self.userID
            } else {
                if let id = Int(vkSingleton.shared.userID) {
                    self.fromID = id
                }
            }
        }
        
        if self.body == "" {
            self.body = json["text"].stringValue
        }
        
        for attach in self.attachments {
            if attach.photo.count > 0 {
                self.attachCount += 1
            }
        }
    }
}

extension Dialog: Equatable {
    
    static func == (lhs: Dialog, rhs: Dialog) -> Bool {
        if lhs.id == rhs.id && lhs.fromID == rhs.fromID {
            return true
        }
        return false
    }
    
    var canEdit: Bool {
        if self.out == 0 {
            return false
        }
        
        if Int(Date().timeIntervalSince1970) - self.date >= 24 * 60 * 60 {
            return false
        }
        
        if self.body == "" {
            for attach in self.attachments {
                if attach.type == "sticker" && attach.sticker.count > 0 {
                    return false
                }
                
                if attach.type == "wall" && attach.record.count > 0 {
                    return false
                }
                
                if attach.type == "doc" && attach.doc.count > 0 {
                    return false
                }
            }
        }
        
        return true
    }
    
    var attachString: String {
        
        var mess = ""
        
        if attachments.count > 0 {
            if attachments.count == 1 {
                if attachments[0].photo.count > 0 {
                    mess = "\(mess)[Фотография]"
                } else if attachments[0].video.count > 0 {
                    mess = "\(mess)[Видеозапись]"
                } else if attachments[0].doc.count > 0 {
                    mess = "\(mess)[Документ]"
                } else if attachments[0].audio.count > 0 {
                    mess = "\(mess)[Аудиозапись]"
                } else if attachments[0].record.count > 0 {
                    mess = "\(mess)[Запись со стены]"
                } else if attachments[0].link.count > 0 {
                    mess = "\(mess)[Внешняя ссылка]"
                } else if attachments[0].poll.count > 0 {
                    mess = "\(mess)[Опрос]"
                } else if attachments[0].sticker.count > 0 {
                    mess = "\(mess)[Стикер]"
                }
            } else {
                mess = "\(mess)[\(attachments.count.attachAdder())]"
            }
        } else {
            if fwdMessages.count > 0 {
                mess = "\(mess)[\(fwdMessages.count.attachAdder())]"
            }
        }
        
        return mess
    }
    
    var lastMessage: String {
        
        var mess = body.replacingOccurrences(of: "\n", with: " ").prepareTextForPublic()
        
        if mess != "" { mess = "\(mess)  " }
        return "\(mess)\(attachString)"
    }
}
