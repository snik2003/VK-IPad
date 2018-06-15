//
//  ReloadGroupsListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupsListController: Operation {
    var controller: GroupsListController
    
    init(controller: GroupsListController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroups = dependencies.first as? ParseGroupList else { return }
        controller.groups = parseGroups.outputData
        controller.groupsList = parseGroups.outputData
        
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .singleLine
        ViewControllerUtils().hideActivityIndicator()
    }
}
