//
//  ErrorJson.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ErrorJson {
    var errorCode: Int = 0
    var errorMsg: String = ""
    
    init(json: JSON) {
        self.errorCode = json["error_code"].intValue
        self.errorMsg = json["error_msg"].stringValue
    }
}
