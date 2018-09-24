//
//  PhotoAlbumsListCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PhotoAlbumsListCell: UITableViewCell {
    
    var delegate: UIViewController!
    var albums: [PhotoAlbum]!
    
    var indexPath: IndexPath!
    var cellWidth: CGFloat = 0
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        for ind in 0...1 {
            let index = 2 * indexPath.row + ind
            
            if index < albums.count {
                let album = albums[index]
                
                let coverImage = UIImageView()
                coverImage.tag = 250
                
                coverImage.image = UIImage(named: "nophoto")
                coverImage.contentMode = .scaleAspectFill
                coverImage.clipsToBounds = true
                
                let getCacheImage = GetCacheImage(url: album.thumbSrc, lifeTime: .userPhotoImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        coverImage.image = getCacheImage.outputImage
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation {
                    coverImage.contentMode = .scaleAspectFill
                    coverImage.clipsToBounds = true
                }
                
                let coverX: CGFloat = 5 + CGFloat(ind) * cellWidth * 0.5
                let coverY: CGFloat = 40
                
                let width: CGFloat = cellWidth * 0.5 - 5
                let height: CGFloat = cellWidth * 0.5 * CGFloat(240) / CGFloat(320) - 5
                
                coverImage.frame = CGRect(x: coverX, y: coverY, width: width, height: height)
                
                self.addSubview(coverImage)
                
                let nameLabel = UILabel()
                nameLabel.tag = 250
                nameLabel.text = album.title
                nameLabel.font = UIFont(name: "Verdana", size: 15)!
                nameLabel.contentMode = .bottom
                nameLabel.textAlignment = .center
                nameLabel.numberOfLines = 2
                nameLabel.adjustsFontSizeToFitWidth = true
                nameLabel.minimumScaleFactor = 0.6
                
                nameLabel.frame = CGRect(x: 10 + CGFloat(ind) * cellWidth * 0.5, y: 0, width: width - 10, height: 40)
                self.addSubview(nameLabel)
                
                
                let countLabel = UILabel()
                countLabel.tag = 250
                countLabel.text = "\(album.size) фото"
                countLabel.font = UIFont(name: "Verdana", size: 14)!
                countLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
                countLabel.contentMode = .bottom
                countLabel.textAlignment = .center
                countLabel.numberOfLines = 1
                
                countLabel.frame = CGRect(x: 0, y: height - 20, width: width, height: 20)
                coverImage.addSubview(countLabel)
                
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = 1
                coverImage.addGestureRecognizer(tap)
                coverImage.isUserInteractionEnabled = true
                tap.add {
                    if let controller = self.delegate as? PhotosListController {
                        if controller.source == "add_photo" {
                            controller.selectIndex = 0
                            controller.ownerID = "\(album.ownerID)"
                            controller.albumID = "\(album.id)"
                            controller.type = "album"
                            
                            /*controller.photos.removeAll(keepingCapacity: false)
                            controller.albums.removeAll(keepingCapacity: false)
                            controller.tableView.reloadData()*/
                            
                            controller.selectButton.isEnabled = false
                            controller.selectButton.title = "Вложить"
                            
                            controller.offset = 0
                            controller.tableView.separatorStyle = .none
                            controller.tableView.frame = CGRect(x: 0, y: 0, width: controller.view.bounds.width, height: controller.view.bounds.height)
                            ViewControllerUtils().showActivityIndicator2(controller: controller)
                            
                            controller.getPhotos()
                        } else {
                            self.delegate.openAlbumController(ownerID: "\(album.ownerID)", albumID: "\(album.id)", title: "Альбом «\(album.title)»")
                        }
                    } else {
                        self.delegate.openAlbumController(ownerID: "\(album.ownerID)", albumID: "\(album.id)", title: "Альбом «\(album.title)»")
                    }
                }
            }
        }
    }
}
