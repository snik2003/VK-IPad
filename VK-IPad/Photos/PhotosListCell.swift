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
    var cellWidth: CGFloat = 0
    
    var markCheck: [BEMCheckBox?] = [nil, nil, nil]
    
    
    func configureCell() {
        
        self.removeAllSubviews()
        
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
                
                if source != "" && source != "change_avatar" {
                    let markCheck = BEMCheckBox()
                    markCheck.tag = 200
                    markCheck.onTintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                    markCheck.onCheckColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                    markCheck.lineWidth = 2
                    
                    markCheck.isEnabled = false
                    markCheck.on = false
                    
                    if let vc = delegate as? PhotosListController {
                        if vc.markPhotos[photo.id] != nil {
                            markCheck.on = true
                        }
                    }
                    
                    if markCheck.on == true {
                        let markImage = UIImageView()
                        markImage.tag = 250
                        markImage.backgroundColor = UIColor.white.withAlphaComponent(0.75)
                        markImage.frame = CGRect(x: photoX, y: photoY, width: photoWidth, height: photoHeight)
                        self.addSubview(markImage)
                    }
                    
                    markCheck.frame = CGRect(x: photoX + 5, y: photoY + 5, width: 20, height: 20)
                    self.addSubview(markCheck)
                } else {
                    let tap = UITapGestureRecognizer()
                    tap.numberOfTapsRequired = 1
                    photoView.addGestureRecognizer(tap)
                    photoView.isUserInteractionEnabled = true
                    tap.add {
                        self.delegate.openPhotoViewController(numPhoto: index, photos: self.photos)
                    }
                }
            }
        }
    }
}
