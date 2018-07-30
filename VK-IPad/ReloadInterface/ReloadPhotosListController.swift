//
//  ReloadPhotosListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadPhotosListController: Operation {
    var controller: PhotosListController
    
    init(controller: PhotosListController) {
        self.controller = controller
    }
    
    override func main() {
        if controller.type != "album" {
            guard let parsePhotos = dependencies[0] as? ParsePhotosList, let parseAlbums = dependencies[1] as? ParsePhotoAlbums else { return }
            
            controller.albums = parseAlbums.outputData
            controller.photosCount = parsePhotos.count
            
            controller.segmentedControl.selectedSegmentIndex = controller.selectIndex
            controller.segmentedControl.setTitle("Все фотографии (\(controller.photosCount))", forSegmentAt: 0)
            controller.segmentedControl.setTitle("Альбомы (\(controller.albums.count))", forSegmentAt: 1)
            
            switch controller.selectIndex {
            case 0:
                if controller.offset == 0 {
                    controller.photos = parsePhotos.outputData
                } else {
                    for index in 0...parsePhotos.outputData.count-1 {
                        controller.photos.append(parsePhotos.outputData[index])
                    }
                }
                controller.heightRow = (controller.view.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
            case 1:
                controller.photos = parsePhotos.outputData
                controller.heightRow = (controller.view.bounds.width * 0.5) * CGFloat(240) / CGFloat(320) + 50
            default:
                break
            }
            
            controller.offset += controller.count
            controller.tableView.estimatedRowHeight = controller.heightRow
            controller.tableView.rowHeight = controller.heightRow
            controller.tableView.reloadData()
            controller.tableView.separatorStyle = .none
            ViewControllerUtils().hideActivityIndicator()
        } else {
            guard let parsePhotos = dependencies[0] as? ParsePhotosList else { return }
            
            controller.photosCount = parsePhotos.count
            
            if controller.offset == 0 {
                controller.photos = parsePhotos.outputData
            } else {
                for index in 0...parsePhotos.outputData.count-1 {
                    controller.photos.append(parsePhotos.outputData[index])
                }
            }
            controller.heightRow = (controller.view.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
            
            controller.segmentedControl.isHidden = true
            controller.segmentedControl.isEnabled = false
            
            controller.offset += controller.count
            controller.tableView.estimatedRowHeight = controller.heightRow
            controller.tableView.rowHeight = controller.heightRow
            controller.tableView.reloadData()
            controller.tableView.separatorStyle = .none
            ViewControllerUtils().hideActivityIndicator()
        }
    }
}
