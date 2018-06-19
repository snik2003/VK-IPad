//
//  ParseWall.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseWall: Operation {
    
    var wall: [Record] = []
    var profiles: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        let wallData = json["response"]["items"].compactMap { Record(json: $0.1) }
        let profilesData = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
        
        wall = wallData
        profiles = profilesData
        groups = groupsData
    }
}
