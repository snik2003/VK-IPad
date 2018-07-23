//
//  FaveLinks.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class FaveLinks {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var photoURL: String = ""
    var url: String = ""
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.photoURL = json["photo_200"].stringValue
        self.url = json["url"].stringValue
    }
}
