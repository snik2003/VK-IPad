//
//  Photos.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Photos {
    var uid: String = ""
    var pid: String = ""
    var createdTime: Int = 0
    var width: Int = 0
    var height: Int = 0
    var photoURL: String = ""
    var photoAccessKey: String = ""
    var smallPhotoURL: String = ""
    var bigPhotoURL: String = ""
    var xbigPhotoURL: String = ""
    var xxbigPhotoURL: String = ""
    
    init(json: JSON) {
        self.uid = json["owner_id"].stringValue
        self.pid = json["id"].stringValue
        self.createdTime = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photoURL = json["photo_130"].stringValue
        self.photoAccessKey = json["access_key"].stringValue
        self.smallPhotoURL = json["photo_75"].stringValue
        self.bigPhotoURL = json["photo_604"].stringValue
        self.xbigPhotoURL = json["photo_807"].stringValue
        self.xxbigPhotoURL = json["photo_1204"].stringValue
    }
}

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
    }
}
