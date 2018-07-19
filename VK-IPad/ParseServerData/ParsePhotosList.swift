//
//  ParsePhotosList.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParsePhotosList: Operation {
    
    var outputData: [Photo] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        outputData = json["response"]["items"].compactMap { Photo(json: $0.1) }
        count = json["response"]["count"].intValue
    }
}
