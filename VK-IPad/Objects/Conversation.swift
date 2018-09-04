//
//  Conversation.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 04.09.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Conversation {
    var peerID = 0
    var type = ""
    var localID = 0
    var inRead = 0
    var outRead = 0
    var unreadCount = 0
    var important = 0
    var unanswered = 0
    
    var disabledUntil = 0
    var disabledForever = 0
    var noSound = 0
    
    var canWrite = 0
    var canWriteReason = 0
    
    var chatSettings: ChatSettings!
    
    init(json: JSON) {
        self.peerID = json["conversation"]["peer"]["id"].intValue
        self.type = json["conversation"]["peer"]["type"].stringValue
        self.localID = json["conversation"]["peer"]["local_id"].intValue
        self.inRead = json["conversation"]["in_read"].intValue
        self.outRead = json["conversation"]["out_read"].intValue
        self.unreadCount = json["conversation"]["unread_count"].intValue
        self.important = json["conversation"]["important"].intValue
        self.unanswered = json["conversation"]["unanswered"].intValue
        
        self.disabledUntil = json["conversation"]["push_settings"]["disabled_until"].intValue
        self.disabledForever = json["conversation"]["push_settings"]["disabled_forever"].intValue
        self.noSound = json["conversation"]["push_settings"]["no_sound"].intValue
        
        self.canWrite = json["conversation"]["can_write"]["allowed"].intValue
        self.canWriteReason = json["conversation"]["can_write"]["reason"].intValue
        
        self.chatSettings = ChatSettings(json: JSON.null)
        self.chatSettings.membersCount = json["conversation"]["chat_settings"]["members_count"].intValue
        self.chatSettings.title = json["conversation"]["chat_settings"]["title"].stringValue
        self.chatSettings.pinnedMessage = json["conversation"]["chat_settings"]["pinned_message"].compactMap { Dialog(json: $0.1) }
        self.chatSettings.state = json["conversation"]["chat_settings"]["state"].stringValue
        self.chatSettings.photo50 = json["conversation"]["chat_settings"]["photo"]["photo_50"].stringValue
        self.chatSettings.photo100 = json["conversation"]["chat_settings"]["photo"]["photo_100"].stringValue
        self.chatSettings.photo200 = json["conversation"]["chat_settings"]["photo"]["photo_200"].stringValue
        self.chatSettings.isGroupChannel = json["conversation"]["chat_settings"]["members_count"].intValue
    }
}

struct ChatSettings {
    var membersCount = 0
    var title = ""
    var pinnedMessage: [Dialog] = []
    var state = ""
    var photo50 = ""
    var photo100 = ""
    var photo200 = ""
    var isGroupChannel = 0
    
    init(json: JSON) {
        self.membersCount = json["members_count"].intValue
        self.title = json["title"].stringValue
        self.pinnedMessage = json["pinned_message"].compactMap { Dialog(json: $0.1) }
        self.state = json["state"].stringValue
        self.photo50 = json["photo"]["photo_50"].stringValue
        self.photo100 = json["photo"]["photo_100"].stringValue
        self.photo200 = json["photo"]["photo_200"].stringValue
        self.isGroupChannel = json["members_count"].intValue
    }
}
