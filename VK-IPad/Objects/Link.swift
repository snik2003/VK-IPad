//
//  Link.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Link {
    var url = ""
    var title = ""
    var caption = ""
    var description = ""
    var photo: [Photo] = []
    
    init(json: JSON) {
        self.url = json["url"].stringValue
        self.title = json["title"].stringValue
        self.caption = json["caption"].stringValue
        self.description = json["description"].stringValue
        
        let photo = Photo(json: JSON.null)
        photo.id = json["photo"]["id"].intValue
        photo.albumID = json["photo"]["album_id"].intValue
        photo.ownerID = json["photo"]["owner_id"].intValue
        photo.userID = json["photo"]["user_id"].intValue
        photo.text = json["photo"]["text"].stringValue
        photo.date = json["photo"]["date"].intValue
        photo.width = json["photo"]["width"].intValue
        photo.height = json["photo"]["height"].intValue
        photo.photo75 = json["photo"]["photo_75"].stringValue
        photo.photo130 = json["photo"]["photo_130"].stringValue
        photo.photo604 = json["photo"]["photo_604"].stringValue
        photo.photo807 = json["photo"]["photo_807"].stringValue
        photo.photo1280 = json["photo"]["photo_1280"].stringValue
        photo.photo2560 = json["photo"]["photo_2560"].stringValue
        self.photo.append(photo)
    }
}
