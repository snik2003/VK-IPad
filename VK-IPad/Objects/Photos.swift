//
//  Photos.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Photo {
    var id = 0
    var albumID = 0
    var ownerID = 0
    var userID = 0
    var text: String = ""
    var date: Int = 0
    var width: Int = 0
    var height: Int = 0
    var photo75 = ""
    var photo130 = ""
    var photo604 = ""
    var photo807 = ""
    var photo1280 = ""
    var photo2560 = ""
    var accessKey = ""
    
    var commentsCount = 0
    var canComment = 0
    var likesCount = 0
    var userLikes = 0
    var tagsCount = 0
    var userCanRepost = 0
    var repostCount = 0
    var userReposted = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.albumID = json["album_id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.userID = json["user_id"].intValue
        self.text = json["text"].stringValue
        self.date = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photo75 = json["photo_75"].stringValue
        self.photo130 = json["photo_130"].stringValue
        self.photo604 = json["photo_604"].stringValue
        self.photo807 = json["photo_807"].stringValue
        self.photo1280 = json["photo_1280"].stringValue
        self.photo2560 = json["photo_2560"].stringValue
        self.accessKey = json["access_key"].stringValue
        
        self.canComment = json["can_comment"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.userCanRepost = json["can_repost"].intValue
        self.repostCount = json["reposts"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
    }
}
