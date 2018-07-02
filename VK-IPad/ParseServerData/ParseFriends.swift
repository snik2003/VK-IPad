//
//  ParseFriends.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseFriendList: Operation {
    
    var outputData: [Friends] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        let users = json["response"]["items"].compactMap { Friends(json: $0.1) }
        count = json["response"]["count"].intValue
        outputData = users
    }
}
