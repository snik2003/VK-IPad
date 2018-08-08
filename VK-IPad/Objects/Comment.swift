//
//  Comment.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Comment {
    var id: Int = 0
    var fromID: Int = 0
    var date: Int = 0
    var text: String = ""
    var canLike = 0
    var userLikes = 0
    var countLikes = 0
    var replyUser = 0
    var replyComment = 0
    
    var attachments: [Attachment] = []
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.fromID = json["from_id"].intValue
        self.date = json["date"].intValue
        self.text = json["text"].stringValue
        self.canLike = json["likes"]["can_like"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.replyUser = json["reply_to_user"].intValue
        self.replyComment = json["reply_to_comment"].intValue
        
        self.attachments = json["attachments"].compactMap({ Attachment(json: $0.1) })
    }
}

extension Comment {
    
    var isSticker: Bool {
        var res = false
        for attach in self.attachments {
            if attach.sticker.count > 0 {
                res = true
            }
        }
        return res
    }
}
