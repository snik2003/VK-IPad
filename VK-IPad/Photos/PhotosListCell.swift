//
//  PhotosListCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox

class PhotosListCell: UITableViewCell {
    
    var delegate: UIViewController!
    
    var photos: [Photo]!
    
    var indexPath: IndexPath!
    var tableView: UITableView!
    
    var cellWidth: CGFloat = 0
    var source: String = ""
    
    var markCheck: [BEMCheckBox] = []
    var fadeImage: [UIImageView] = []
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        markCheck.removeAll(keepingCapacity: false)
        fadeImage.removeAll(keepingCapacity: false)
        
        for ind in 0...2 {
            let index = 3 * indexPath.row + ind
            
            if index < photos.count {
                let photoView = UIImageView()
                photoView.tag = 250
                
                photoView.image = UIImage(named: "nophoto")
                photoView.contentMode = .scaleAspectFill
                photoView.clipsToBounds = true
                
                var source = ""
                if let vc = delegate as? PhotosListController {
                    source = vc.source
                }
                
                let photo = photos[index]
                
                var url = photo.photo807
                if url == "" {
                    url = photo.photo604
                    if url == "" {
                        url = photo.photo130
                    }
                }
                
                let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        photoView.image = getCacheImage.outputImage
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation {
                    photoView.contentMode = .scaleAspectFill
                    photoView.clipsToBounds = true
                }
                
                let photoX: CGFloat = 3 + CGFloat(ind) * cellWidth * 0.333
                let photoY: CGFloat = 3
                
                let photoWidth: CGFloat = cellWidth * 0.333 - 3
                let photoHeight: CGFloat = (photoWidth + 3) * CGFloat(240) / CGFloat(320) - 3
                
                photoView.frame = CGRect(x: photoX, y: photoY, width: photoWidth, height: photoHeight)
                self.addSubview(photoView)
                
                if source == "add_photo" {
                    let tap = UITapGestureRecognizer()
                    tap.numberOfTapsRequired = 1
                    photoView.addGestureRecognizer(tap)
                    photoView.isUserInteractionEnabled = true
                    tap.add {
                        self.photos[index].isSelected = !self.photos[index].isSelected
                        self.setSelected()
                    }
                } else {
                    let tap = UITapGestureRecognizer()
                    tap.numberOfTapsRequired = 1
                    photoView.addGestureRecognizer(tap)
                    photoView.isUserInteractionEnabled = true
                    tap.add {
                        self.delegate.openPhotoViewController(numPhoto: index, photos: self.photos)
                    }
                }
                
                if source != "" {
                    let markCheck = BEMCheckBox()
                    markCheck.tag = 250
                    markCheck.onTintColor = vkSingleton.shared.mainColor
                    markCheck.onCheckColor = vkSingleton.shared.mainColor
                    markCheck.lineWidth = 3
                    
                    markCheck.on = photo.isSelected
                    
                    markCheck.frame = CGRect(x: photoX + 5, y: photoY + 5, width: 20, height: 20)
                    self.addSubview(markCheck)
                    
                    let fadeImage = UIImageView()
                    fadeImage.tag = 250
                    if photo.isSelected {
                        fadeImage.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.75)
                    } else {
                        fadeImage.backgroundColor = UIColor.clear
                    }
                    fadeImage.frame = photoView.frame
                    
                    self.addSubview(fadeImage)
                    self.addSubview(markCheck)
                    
                    self.markCheck.append(markCheck)
                    self.fadeImage.append(fadeImage)
                }
            }
        }
    }
    
    func setSelected() {
        
        for ind in 0...2 {
            let index = 3 * indexPath.row + ind
            
            if index < photos.count {
                markCheck[ind].on = self.photos[index].isSelected
                
                if self.photos[index].isSelected {
                    fadeImage[ind].backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.75)
                } else {
                    fadeImage[ind].backgroundColor = UIColor.clear
                }
                
                
                if let controller = self.delegate as? PhotosListController {
                    let photos = controller.photos.filter({ $0.isSelected == true })
                    
                    if photos.count > 0 {
                        controller.selectButton.isEnabled = true
                        controller.selectButton.title = "Вложить (\(photos.count))"
                    } else {
                        controller.selectButton.isEnabled = false
                        controller.selectButton.title = "Вложить"
                    }
                }
            }
        }
    }
}
