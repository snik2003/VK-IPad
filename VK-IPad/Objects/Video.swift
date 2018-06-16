//
//  Video.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Video {
    var id = 0
    var ownerID = 0
    var title = ""
    var description = ""
    var duration = 0
    var photo130 = ""
    var photo320 = ""
    var photo640 = ""
    var photo800 = ""
    var date = 0
    var addingDate = 0
    var views = 0
    var comments = 0
    var player = ""
    var platform = ""
    var canEdit = 0
    var canAdd = 0
    var isPrivate = 0
    var accessKey = ""
    var processing = 0
    var live = 0
    var upcoming = 0

    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.duration = json["duration"].intValue
        self.photo130 = json["photo_130"].stringValue
        self.photo320 = json["photo_320"].stringValue
        self.photo640 = json["photo_640"].stringValue
        self.photo800 = json["photo_800"].stringValue
        self.date = json["date"].intValue
        self.addingDate = json["adding_date"].intValue
        self.views = json["views"].intValue
        self.comments = json["comments"].intValue
        self.player = json["player"].stringValue
        self.platform = json["platform"].stringValue
        self.canEdit = json["can_edit"].intValue
        self.canAdd = json["can_add"].intValue
        self.isPrivate = json["is_private"].intValue
        self.accessKey = json["access_key"].stringValue
        self.processing = json["processing"].intValue
        self.live = json["live"].intValue
        self.upcoming = json["upcoming"].intValue
    }
}
