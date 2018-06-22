//
//  ReloadVideoListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 22.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadVideoListController: Operation {
    var controller: VideoListController
    
    init(controller: VideoListController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseVideos = dependencies.first as? ParseVideos else { return }
        
        if controller.offset == 0 {
            controller.videos = parseVideos.outputData
            controller.requestVideos = parseVideos.outputData
        } else {
            if controller.offset < parseVideos.count {
                if parseVideos.outputData.count > 0 {
                    for index in 0...parseVideos.outputData.count-1 {
                        controller.videos.append(parseVideos.outputData[index])
                        controller.requestVideos.append(parseVideos.outputData[index])
                    }
                }
            }
        }
        
        if controller.type != "search" {
            controller.offset += controller.count
        }
        controller.tableView.estimatedRowHeight = controller.tableView.bounds.width * 0.5 * CGFloat(240) / CGFloat(320)
        controller.tableView.rowHeight = controller.tableView.bounds.width * 0.5 * CGFloat(240) / CGFloat(320)
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
