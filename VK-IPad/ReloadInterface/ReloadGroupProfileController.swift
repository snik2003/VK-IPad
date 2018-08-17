//
//  ReloadGroupProfileController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupProfileController: Operation {
    
    var controller: GroupProfileViewController
    
    init(controller: GroupProfileViewController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroupWall = dependencies[0] as? ParseWall, let parseGroupProfile = dependencies[1] as? ParseGroupProfile, let parsePostponed = dependencies[2] as? ParseWall, let parseSuggested = dependencies[3] as? ParseWall else { return }
        
        controller.recordsCount = parseGroupWall.count
        
        controller.suggestedWall = parseSuggested.wall
        
        controller.postponedWall = parsePostponed.wall
        controller.postponedWallProfiles = parsePostponed.profiles
        controller.postponedWallGroups = parsePostponed.groups
        
        if controller.offset == 0 {
            controller.wall = parseGroupWall.wall
            controller.wallProfiles = parseGroupWall.profiles
            controller.wallGroups = parseGroupWall.groups
        } else {
            for record in parseGroupWall.wall {
                controller.wall.append(record)
            }
            for profile in parseGroupWall.profiles {
                controller.wallProfiles.append(profile)
            }
            for group in parseGroupWall.groups {
                controller.wallGroups.append(group)
            }
        }
        controller.groupProfile = parseGroupProfile.outputData
        controller.offset += controller.count
        
        if controller.groupProfile.count > 0 {
            let group = controller.groupProfile[0]
            controller.title = group.name
        }
        
        controller.setProfileView()
        controller.tableView.reloadData()
        controller.tableView.isHidden = false
        controller.refreshControl?.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}
