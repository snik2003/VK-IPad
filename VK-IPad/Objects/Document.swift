//
//  Document.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Document {
    var id = 0
    var ownerID = 0
    var title = ""
    var size = 0
    var ext = ""
    var url = ""
    var date = 0
    var type = 0
    var photoURL: [String] = []
    var width = 0
    var height = 0
    var videoURL = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.size = json["size"].intValue
        self.ext = json["ext"].stringValue
        self.url = json["url"].stringValue
        self.date = json["date"].intValue
        self.type = json["type"].intValue
        
        for index in 0...3 {
            let url = json["preview"]["photo"]["sizes"][index]["src"].stringValue
            if url != "" {
                self.photoURL.append(url)
            }
        }
        self.videoURL = json["preview"]["video"]["src"].stringValue
        self.width = json["preview"]["video"]["width"].intValue
        self.height = json["preview"]["video"]["height"].intValue
    }
}
