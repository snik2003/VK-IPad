//
//  Notification.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 10.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notification {
    var type = ""
    var date = 0
    var feedbackCount = 0
    var feedback: [NotificationFeedback] = []
    var parent: NotificationParent
    var reply: NotificationReply
    
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.date = json["date"].intValue
        self.feedbackCount = json["feedback"]["count"].intValue
        
        if self.feedbackCount > 0 {
            for index in 0...self.feedbackCount-1 {
                self.feedback.append(NotificationFeedback(json: json["feedback"]["items"][index]))
            }
        }
        
        self.parent = NotificationParent(json: json["parent"], type: self.type)
        self.reply = NotificationReply(json: json["reply"])
    }
}

class NotificationFeedback {
    var count = 0
    var id = 0
    var toID = 0
    var fromID = 0
    var text = ""
    var likesCount = 0
    var userLikes = 0
    var canLike = 0
    var canPost = 0
    
    init(json: JSON) {
        self.count = json["count"].intValue
        self.id = json["id"].intValue
        self.toID = json["to_id"].intValue
        self.fromID = json["from_id"].intValue
        self.text = json["text"].stringValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.canLike = json["likes"]["can_like"].intValue
        self.canPost = json["likes"]["can_publish"].intValue
    }
}

class NotificationParent {
    var post: Record!
    var photo: Photo!
    var video: Video!
    var comment: Comment!
    
    init(json: JSON, type: String) {
        if type == "mention_comments" || type == "comment_post" || type == "like_post" || type == "copy_post" {
            self.post = Record(json: json)
        }
        
        if type == "comment_photo" || type == "like_photo" || type == "copy_photo" || type == "mention_comment_photo" {
            self.photo = Photo(json: json)
        }
        
        if type == "comment_video" || type == "like_video" || type == "copy_video" || type == "mention_comment_video" {
            self.video = Video(json: json)
        }
        
        if type == "reply_comment" || type == "reply_comment_photo" || type == "reply_comment_video" || type == "like_comment" || type == "like_comment_photo" || type == "like_comment_video" || type == "like_comment_topic" {
            self.comment = Comment(json: json)
        }
    }
}

class NotificationReply {
    var id = 0
    var date = 0
    var text = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.date = json["date"].intValue
        self.text = json["text"].stringValue
    }
}
