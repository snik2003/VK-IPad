//
//  ReloadTopicController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 31.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadTopicController: Operation {
    var controller: TopicController
    
    init(controller: TopicController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseComments = dependencies[0] as? ParseComments, let parseTopics = dependencies[1] as? ParseTopics, let parseGroupProfile = dependencies[2] as? ParseGroupProfile else { return }
        
        if controller.offset == 0 {
            controller.comments = parseComments.comments
            controller.users = parseComments.users
            controller.groups = parseComments.groups
        } else {
            for comment in parseComments.comments {
                controller.comments.append(comment)
            }
            for user in parseComments.users {
                controller.users.append(user)
            }
            for group in parseComments.groups {
                controller.groups.append(group)
            }
        }
        
        controller.total = parseComments.count
        
        controller.topics = parseTopics.outputData
        controller.topicUsers = parseTopics.users
        
        if controller.topics.count > 0 {
            controller.title = "Обсуждение «\(controller.topics[0].title)»"
            if controller.topics[0].isClosed == 1 {
                controller.tableView.frame = CGRect(x: 0, y: 0, width: controller.width, height: controller.view.bounds.height)
                controller.view.addSubview(controller.tableView)
                controller.commentView.removeFromSuperview()
            } else {
                controller.view.addSubview(controller.commentView)
            }
        }
        
        controller.group = parseGroupProfile.outputData
        if controller.group.count > 0 {
            if controller.group[0].isAdmin == 1 && controller.topics.count > 0 {
                controller.optButton = UIBarButtonItem(barButtonSystemItem: .action, target: controller, action: #selector(controller.tapBarButtonItem(sender:)))
                controller.navigationItem.rightBarButtonItem = controller.optButton
            }
        }
        
        controller.offset += controller.count
        controller.tableView.separatorStyle = .singleLine
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
