//
//  Sticker.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 21.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Sticker {
    var productID: Int = 0
    var stickerID: Int = 0
    var url: String = ""
    var width: Int = 0
    var height: Int = 0
    
    init(json: JSON) {
        self.productID = json["product_id"].intValue
        self.stickerID = json["id"].intValue
        self.url = json["photo_256"].stringValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
    }
}
