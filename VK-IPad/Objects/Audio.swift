//
//  Audio.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Audio {
    var id = 0
    var ownerID = 0
    var artist = ""
    var title = ""
    var duration = 0
    var url = 0
    var albumID = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.artist = json["artist"].stringValue
        self.title = json["title"].stringValue
        self.duration = json["duration"].intValue
        self.url = json["url"].intValue
        self.albumID = json["album_id"].intValue
    }
}
