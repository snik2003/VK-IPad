//
//  AttachmentsView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 18.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class AttachmentsView: UIView {

    var delegate: UIViewController!
    
    var photos: [Photo] = []
    
    func configureAttachView(attaches: [Attachment], maxSize: CGFloat, getRow: Bool) -> CGFloat {
        
        var maxSize = maxSize
        
        photos.removeAll(keepingCapacity: false)
        for attach in attaches {
            if attach.photo.count > 0 {
                photos.append(attach.photo[0])
            }
            
            /*if attach.doc.count > 0 && attach.doc[0].ext == "png" {
                let photo = Photo(json: JSON.null)
                photo.id = attach.doc[0].id
                photo.ownerID = attach.doc[0].ownerID
                photo.userID = attach.doc[0].ownerID
                photo.text = attach.doc[0].title
                photo.date = attach.doc[0].date
                photo.width = attach.doc[0].width
                photo.height = attach.doc[0].height
                photo.photo75 = attach.doc[0].photoURL[0]
                if attach.doc[0].photoURL.count > 0 {
                    photo.photo130 = attach.doc[0].photoURL[attach.doc[0].photoURL.count-1]
                    photo.photo604 = photo.photo130
                    photo.photo807 = photo.photo130
                    photo.photo1280 = photo.photo130
                    photo.photo2560 = photo.photo130
                }
                photo.accessKey = attach.doc[0].accessKey
                photos.append(photo)
            }*/
        }
        
        var topY: CGFloat = 0
        
        if photos.count > 0 {
            switch photos.count {
            case 1:
                if photos[0].width > 0, photos[0].height > 0 {
                    var width = CGFloat(photos[0].width)
                    var height = CGFloat(photos[0].height)
                    
                    if width > height {
                        width = maxSize
                        height = width * CGFloat(photos[0].height) / CGFloat(photos[0].width)
                    } else {
                        height = maxSize
                        width = height * CGFloat(photos[0].width) / CGFloat(photos[0].height)
                    }
                    
                    if !getRow {
                        let photoImage = UIImageView()
                        photoImage.image = UIImage(named: "nophoto")
                        photoImage.contentMode = .scaleAspectFill
                        photoImage.tag = 250
                        
                        var url = photos[0].photo1280
                        if url == "" {
                            url = photos[0].photo807
                            if url == "" {
                                url = photos[0].photo604
                            }
                            if url == "" {
                                url = photos[0].photo130
                            }
                        }
                        let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                photoImage.image = getCacheImage.outputImage
                                photoImage.clipsToBounds = true
                                if width > height {
                                    photoImage.contentMode = .scaleAspectFill
                                } else {
                                    photoImage.contentMode = .scaleAspectFit
                                }
                            }
                        }
                        OperationQueue().addOperation(getCacheImage)
                        
                        photoImage.frame = CGRect(x: 0, y: topY + 2.5, width: width, height: height)
                        photoImage.clipsToBounds = true
                        self.addSubview(photoImage)
                        
                        let tap = UITapGestureRecognizer()
                        photoImage.isUserInteractionEnabled = true
                        photoImage.addGestureRecognizer(tap)
                        tap.add {
                            self.delegate.openPhotoViewController(numPhoto: 0, photos: self.photos)
                        }
                        
                        maxSize = width
                    }
                    topY += height + 2.5
                }
            case 3,5,7,9:
                
                var width = CGFloat(photos[0].width)
                var height = CGFloat(photos[0].height)
                
                if width > height {
                    width = maxSize
                    height = width * CGFloat(photos[0].height) / CGFloat(photos[0].width)
                } else {
                    height = maxSize
                    width = maxSize
                }
                
                if !getRow {
                    let photoImage = UIImageView()
                    photoImage.image = UIImage(named: "nophoto")
                    photoImage.contentMode = .scaleAspectFill
                    photoImage.tag = 250
                    
                    var url = photos[0].photo1280
                    if url == "" {
                        url = photos[0].photo807
                        if url == "" {
                            url = photos[0].photo604
                        }
                        if url == "" {
                            url = photos[0].photo130
                        }
                    }
                    let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            photoImage.image = getCacheImage.outputImage
                            photoImage.clipsToBounds = true
                            photoImage.contentMode = .scaleAspectFill
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                    
                    photoImage.frame = CGRect(x: 0, y: topY + 2.5, width: width, height: height)
                    photoImage.clipsToBounds = true
                    self.addSubview(photoImage)
                    
                    let tap = UITapGestureRecognizer()
                    photoImage.isUserInteractionEnabled = true
                    photoImage.addGestureRecognizer(tap)
                    tap.add {
                        self.delegate.openPhotoViewController(numPhoto: 0, photos: self.photos)
                    }
                }
                topY += height + 2.5
                
                for index in stride(from: 1, to: photos.count, by: 2) {
                    var width1 = CGFloat(photos[index].width)
                    var height1 = CGFloat(photos[index].height)
                    
                    var width2 = CGFloat(photos[index+1].width)
                    var height2 = CGFloat(photos[index+1].height)
                    
                    if width1 > height1 {
                        width1 = maxSize
                        height1 = width1 * CGFloat(photos[index].height) / CGFloat(photos[index].width)
                    } else {
                        height1 = maxSize
                        width1 = height1 * CGFloat(photos[index].width) / CGFloat(photos[index].height)
                    }
                    
                    if width2 > height2 {
                        width2 = maxSize
                        height2 = width2 * CGFloat(photos[index+1].height) / CGFloat(photos[index+1].width)
                    } else {
                        height2 = maxSize
                        width2 = height2 * CGFloat(photos[index+1].width) / CGFloat(photos[index+1].height)
                    }
                    
                    let width11 = width1 * maxSize / (width1 + width2)
                    height1 = width11 * CGFloat(photos[index].height) / CGFloat(photos[index].width)
                    let width22 = width2 * maxSize / (width1 + width2)
                    height2 = width22 * CGFloat(photos[index+1].height) / CGFloat(photos[index+1].width)
                    
                    height1 = min(height1, height2)
                    
                    if !getRow {
                        let photoImage1 = UIImageView()
                        photoImage1.image = UIImage(named: "nophoto")
                        photoImage1.contentMode = .scaleAspectFill
                        photoImage1.tag = 250
                        
                        var url1 = photos[index].photo1280
                        if url1 == "" {
                            url1 = photos[index].photo807
                            if url1 == "" {
                                url1 = photos[index].photo604
                            }
                            if url1 == "" {
                                url1 = photos[index].photo130
                            }
                        }
                        let getCacheImage1 = GetCacheImage(url: url1, lifeTime: .userPhotoImage)
                        getCacheImage1.completionBlock = {
                            OperationQueue.main.addOperation {
                                photoImage1.image = getCacheImage1.outputImage
                                photoImage1.clipsToBounds = true
                                photoImage1.contentMode = .scaleAspectFill
                            }
                        }
                        OperationQueue().addOperation(getCacheImage1)
                        
                        photoImage1.frame = CGRect(x: 0, y: topY + 2.5, width: width11 - 2.5, height: height1)
                        photoImage1.clipsToBounds = true
                        self.addSubview(photoImage1)
                        
                        let tap1 = UITapGestureRecognizer()
                        photoImage1.isUserInteractionEnabled = true
                        photoImage1.addGestureRecognizer(tap1)
                        tap1.add {
                            self.delegate.openPhotoViewController(numPhoto: index, photos: self.photos)
                        }
                        
                        let photoImage2 = UIImageView()
                        photoImage2.image = UIImage(named: "nophoto")
                        photoImage2.contentMode = .scaleAspectFill
                        photoImage2.tag = 250
                        
                        var url2 = photos[index+1].photo1280
                        if url2 == "" {
                            url2 = photos[index+1].photo807
                            if url2 == "" {
                                url2 = photos[index+1].photo604
                            }
                            if url2 == "" {
                                url2 = photos[index+1].photo130
                            }
                        }
                        let getCacheImage2 = GetCacheImage(url: url2, lifeTime: .userPhotoImage)
                        getCacheImage2.completionBlock = {
                            OperationQueue.main.addOperation {
                                photoImage2.image = getCacheImage2.outputImage
                                photoImage2.clipsToBounds = true
                                photoImage2.contentMode = .scaleAspectFill
                            }
                        }
                        OperationQueue().addOperation(getCacheImage2)
                        
                        photoImage2.frame = CGRect(x: width11, y: topY + 2.5, width: width22 - 2.5, height: height1)
                        photoImage2.clipsToBounds = true
                        self.addSubview(photoImage2)
                        
                        let tap2 = UITapGestureRecognizer()
                        photoImage2.isUserInteractionEnabled = true
                        photoImage2.addGestureRecognizer(tap2)
                        tap2.add {
                            self.delegate.openPhotoViewController(numPhoto: index+1, photos: self.photos)
                        }
                    }
                    topY += height1 + 2.5
                }
            case 2,4,6,8,10:
                for index in stride(from: 0, to: photos.count, by: 2) {
                    var width1 = CGFloat(photos[index].width)
                    var height1 = CGFloat(photos[index].height)
                    
                    var width2 = CGFloat(photos[index+1].width)
                    var height2 = CGFloat(photos[index+1].height)
                    
                    if width1 > height1 {
                        width1 = maxSize
                        height1 = width1 * CGFloat(photos[index].height) / CGFloat(photos[index].width)
                    } else {
                        height1 = maxSize
                        width1 = height1 * CGFloat(photos[index].width) / CGFloat(photos[index].height)
                    }
                    
                    if width2 > height2 {
                        width2 = maxSize
                        height2 = width2 * CGFloat(photos[index+1].height) / CGFloat(photos[index+1].width)
                    } else {
                        height2 = maxSize
                        width2 = height2 * CGFloat(photos[index+1].width) / CGFloat(photos[index+1].height)
                    }
                    
                    let width11 = width1 * maxSize / (width1 + width2)
                    height1 = width11 * CGFloat(photos[index].height) / CGFloat(photos[index].width)
                    let width22 = width2 * maxSize / (width1 + width2)
                    height2 = width22 * CGFloat(photos[index+1].height) / CGFloat(photos[index+1].width)
                    
                    height1 = min(height1, height2)
                    
                    if !getRow {
                        let photoImage1 = UIImageView()
                        photoImage1.image = UIImage(named: "nophoto")
                        photoImage1.contentMode = .scaleAspectFill
                        photoImage1.tag = 250
                        
                        var url1 = photos[index].photo1280
                        if url1 == "" {
                            url1 = photos[index].photo807
                            if url1 == "" {
                                url1 = photos[index].photo604
                            }
                            if url1 == "" {
                                url1 = photos[index].photo130
                            }
                        }
                        let getCacheImage1 = GetCacheImage(url: url1, lifeTime: .userPhotoImage)
                        getCacheImage1.completionBlock = {
                            OperationQueue.main.addOperation {
                                photoImage1.image = getCacheImage1.outputImage
                                photoImage1.clipsToBounds = true
                                photoImage1.contentMode = .scaleAspectFill
                            }
                        }
                        OperationQueue().addOperation(getCacheImage1)
                        
                        photoImage1.frame = CGRect(x: 0, y: topY + 2.5, width: width11 - 2.5, height: height1)
                        photoImage1.clipsToBounds = true
                        self.addSubview(photoImage1)
                        
                        let tap1 = UITapGestureRecognizer()
                        photoImage1.isUserInteractionEnabled = true
                        photoImage1.addGestureRecognizer(tap1)
                        tap1.add {
                            self.delegate.openPhotoViewController(numPhoto: index, photos: self.photos)
                        }
                        
                        let photoImage2 = UIImageView()
                        photoImage2.image = UIImage(named: "nophoto")
                        photoImage2.contentMode = .scaleAspectFill
                        photoImage2.tag = 250
                        
                        var url2 = photos[index+1].photo1280
                        if url2 == "" {
                            url2 = photos[index+1].photo807
                            if url2 == "" {
                                url2 = photos[index+1].photo604
                            }
                            if url2 == "" {
                                url2 = photos[index+1].photo130
                            }
                        }
                        let getCacheImage2 = GetCacheImage(url: url2, lifeTime: .userPhotoImage)
                        getCacheImage2.completionBlock = {
                            OperationQueue.main.addOperation {
                                photoImage2.image = getCacheImage2.outputImage
                                photoImage2.clipsToBounds = true
                                photoImage2.contentMode = .scaleAspectFill
                            }
                        }
                        OperationQueue().addOperation(getCacheImage2)
                        
                        photoImage2.frame = CGRect(x: width11, y: topY + 2.5, width: width22 - 2.5, height: height1)
                        photoImage2.clipsToBounds = true
                        self.addSubview(photoImage2)
                        
                        let tap2 = UITapGestureRecognizer()
                        photoImage2.isUserInteractionEnabled = true
                        photoImage2.addGestureRecognizer(tap2)
                        tap2.add {
                            self.delegate.openPhotoViewController(numPhoto: index+1, photos: self.photos)
                        }
                    }
                    topY += height1 + 2.5
                }
            default:
                break
            }
            
            topY += 2.5
        }
        
        self.frame = CGRect(x: 0, y: 0, width: maxSize, height: topY)
        
        return topY
    }
}
