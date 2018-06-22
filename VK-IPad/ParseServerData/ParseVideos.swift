//
//  ParseVideos.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 22.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseVideos: Operation {
    
    var outputData: [Video] = []
    var profiles: [UserProfile] = []
    var groups: [GroupProfile] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        let videos = json["response"]["items"].compactMap { Video(json: $0.1) }
        profiles = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
        groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
        count = json["response"]["count"].intValue
        
        outputData = videos
    }
}
