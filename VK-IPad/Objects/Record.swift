//
//  Record.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Record {
    var id = 0
    var ownerID = 0
    var fromID = 0
    var createdBy = 0
    var date = 0
    var text = ""
    var replyOwnerID = 0
    var replyPostID = 0
    var friendsOnly = 0
    var commentsCount = 0
    var canComment = 0
    var groupCanComment = 0
    var likesCount = 0
    var userLikes = 0
    var userCanLike = 0
    var userCanRepost = 0
    var repostCount = 0
    var userReposted = 0
    var viewsCount = 0
    var postType = ""
    var sourcePlatform = 0
    var signerID = 0
    var canPin = 0
    var canDelete = 0
    var canEdit = 0
    var isPinned = 0
    
    var copy: [Record] = []
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.fromID = json["from_id"].intValue
        self.createdBy = json["created_by"].intValue
        self.date = json["date"].intValue
        self.replyOwnerID = json["reply_owner_id"].intValue
        self.replyPostID = json["reply_post_id"].intValue
        self.friendsOnly = json["friends_only"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.canComment = json["comments"]["can_post"].intValue
        self.groupCanComment = json["comments"]["groups_can_post"].intValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.userCanLike = json["likes"]["can_like"].intValue
        self.userCanRepost = json["likes"]["can_publish"].intValue
        self.repostCount = json["reposts"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
        self.viewsCount = json["views"]["count"].intValue
        self.sourcePlatform = json["post_source"]["platform"].intValue
        self.signerID = json["signer_id"].intValue
        self.canPin = json["can_pin"].intValue
        self.canDelete = json["can_delete"].intValue
        self.canEdit = json["can_edit"].intValue
        self.isPinned = json["is_pinned"].intValue
        
        self.text = json["text"].stringValue
        self.postType = json["post_type"].stringValue
        
        self.copy = json["copy_history"].compactMap({ Record(json: $0.1) })
    }
    
}

struct Attachment {
    
}
