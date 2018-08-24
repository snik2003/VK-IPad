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
    
    var attachCount = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.userID = json["user_id"].intValue
        self.fromID = json["from_id"].intValue
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
        
        for attach in self.attachments {
            if attach.photo.count > 0 {
                self.attachCount += 1
            }
        }
    }
}
