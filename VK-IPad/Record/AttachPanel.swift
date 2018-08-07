//
//  AttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class AttachPanel: UIView {

    var maxAttachCount = 10
    
    var delegate: UIViewController! {
        didSet {
            if !(delegate is TopicController) {
                maxAttachCount = 2
            }
        }
    }
    
    var comments: [Comment] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var replyID = 0 {
        didSet {
            self.removeFromSuperview()
            self.reconfigure()
        }
    }
    
    var editID = 0
    
    var cornerRadius: CGFloat = 6
    
    var attachArray: [AnyObject] = []
    var attachments = ""
    
    func reconfigure() {
        
        removeSubviews()
        self.backgroundColor = UIColor.clear
        
        var height: CGFloat = 0
        
        let width = self.delegate.view.bounds.width - 20
        
        if replyID != 0 {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
            view.layer.cornerRadius = cornerRadius
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            
            let nameLabel = UILabel()
            nameLabel.tag = 250
            nameLabel.text = "Вы отвечаете \(getReplyName(commentID: replyID, label: nameLabel))"
            nameLabel.font = UIFont(name: "Verdana", size: 14)!
            nameLabel.textColor = nameLabel.tintColor
            nameLabel.frame = CGRect(x: 20, y: height, width: width - 40 - 120, height: 30)
            view.addSubview(nameLabel)
            
            
            let xButton = UIButton()
            xButton.tag = 250
            xButton.setTitle("🚫 Отменить", for: .normal)
            xButton.setTitleColor(UIColor.red, for: .normal)
            xButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            xButton.contentHorizontalAlignment = .right
            xButton.add(for: .touchUpInside) {
                if let controller = self.delegate as? RecordController {
                    controller.commentView.textView.text = ""
                } else if let controller = self.delegate as? VideoController {
                    controller.commentView.textView.text = ""
                } else if let controller = self.delegate as? TopicController {
                    controller.commentView.textView.text = ""
                }
                self.replyID = 0
            }
            xButton.frame = CGRect(x: width - 20 - 120, y: height, width: 120, height: 30)
            if editID == 0 {
                view.addSubview(xButton)
            }
            
            view.frame = CGRect(x: 10, y: 10, width: width, height: 30)
            view.dropShadow(color: UIColor.black, opacity: 0.9, offSet: CGSize(width: -1, height: 1), radius: cornerRadius)
            self.addSubview(view)
            height += 40
        }
        
        attachments = ""
        if attachArray.count > 0 {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
            view.layer.cornerRadius = cornerRadius
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            
            var top: CGFloat = 0
            
            let nameLabel = UILabel()
            nameLabel.tag = 250
            nameLabel.text = "Вложения в сообщение/комментарий:"
            nameLabel.font = UIFont(name: "Verdana", size: 14)!
            nameLabel.textColor = UIColor.purple
            nameLabel.textAlignment = .left
            nameLabel.frame = CGRect(x: 20, y: top + 5, width: width - 40, height: 20)
            view.addSubview(nameLabel)
            
            top += 25
            
            for index in 0...attachArray.count-1 {
                let imageView = UIImageView()
                imageView.tag = 250
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.borderColor = UIColor.lightGray.cgColor
                imageView.layer.borderWidth = 0.5
                imageView.frame = CGRect(x: 20, y: top + 5, width: 30, height: 30)
                view.addSubview(imageView)
                
                let nameLabel = UILabel()
                nameLabel.tag = 250
                nameLabel.font = UIFont(name: "Verdana", size: 14)!
                nameLabel.textColor = nameLabel.tintColor
                nameLabel.frame = CGRect(x: 60, y: top, width: width - 40 - 120, height: 40)
                view.addSubview(nameLabel)
                
                let xButton = UIButton()
                xButton.tag = 250
                xButton.setTitle("✘ Удалить", for: .normal)
                xButton.setTitleColor(UIColor.red, for: .normal)
                xButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
                xButton.contentHorizontalAlignment = .right
                
                if let video = attachArray[index] as? Video {
                    let getCacheImage = GetCacheImage(url: video.photo320, lifeTime: .userPhotoImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            imageView.image = getCacheImage.outputImage
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                    
                    if attachments != "" {
                        attachments = "\(attachments),"
                    }
                    attachments = "\(attachments)video\(video.ownerID)_\(video.id)"
 
                    nameLabel.text = "Видеозапись «\(video.title)»"
                    
                    let tap1 = UITapGestureRecognizer()
                    nameLabel.isUserInteractionEnabled = true
                    nameLabel.addGestureRecognizer(tap1)
                    tap1.add {
                        self.delegate.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                    }
                    
                    let tap2 = UITapGestureRecognizer()
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tap2)
                    tap2.add {
                        self.delegate.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                    }
                } else if let photo = attachArray[index] as? Photo {
                    let getCacheImage = GetCacheImage(url: photo.photo604, lifeTime: .userPhotoImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            imageView.image = getCacheImage.outputImage
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                    
                    var text = ""
                    if photo.text != "" {
                        text = "«\(photo.text)»"
                    }
                    
                    if attachments != "" {
                        attachments = "\(attachments),"
                    }
                    attachments = "\(attachments)photo\(photo.ownerID)_\(photo.id)"
                    
                    nameLabel.text = "Фотография \(text)"
                    
                    let tap1 = UITapGestureRecognizer()
                    nameLabel.isUserInteractionEnabled = true
                    nameLabel.addGestureRecognizer(tap1)
                    tap1.add {
                        self.delegate.openWallRecord(ownerID: photo.ownerID, postID: photo.id, accessKey: photo.accessKey, type: "photo")
                    }
                    
                    let tap2 = UITapGestureRecognizer()
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tap2)
                    tap2.add {
                        self.delegate.openWallRecord(ownerID: photo.ownerID, postID: photo.id, accessKey: photo.accessKey, type: "photo")
                    }
                }
                
                xButton.add(for: .touchUpInside) {
                    self.attachArray.remove(at: index)
                    self.removeFromSuperview()
                    self.reconfigure()
                }
                
                xButton.frame = CGRect(x: width - 20 - 120, y: top, width: 120, height: 40)
                view.addSubview(xButton)
                
                top += 40
            }
            
            if attachArray.count > maxAttachCount {
                let maxLabel = UILabel()
                maxLabel.tag = 250
                maxLabel.text = "Внимание! Вы превысили максимальное количество вложений: \(maxAttachCount)"
                maxLabel.font = UIFont(name: "Verdana", size: 13)!
                maxLabel.textColor = UIColor.red
                maxLabel.textAlignment = .center
                maxLabel.frame = CGRect(x: 20, y: top + 5, width: width - 40, height: 20)
                view.addSubview(maxLabel)
                
                top += 30
            }
            
            if replyID == 0 {
                height += 10
            } else {
                height += 5
            }
            view.frame = CGRect(x: 10, y: height, width: width, height: top)
            height += top
            
            view.dropShadow(color: UIColor.black, opacity: 0.9, offSet: CGSize(width: -1, height: 1), radius: cornerRadius)
            self.addSubview(view)
        }
        
        if let controller = delegate as? RecordController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? VideoController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? TopicController {
            controller.commentView.attachCount = attachArray.count
        }
        
        if height > 0 {
            self.frame = CGRect(x: 0, y: 64, width: width + 20, height: height)
            self.delegate.view.addSubview(self)
        }
        
        print("attachments = \(attachments)")
    }
    
    func getReplyName(commentID: Int, label: UILabel) -> String {
        var name = ""
        
        if let comment = comments.filter({ $0.id == commentID }).first {
            if comment.fromID > 0 {
                if let user = users.filter({ $0.uid == "\(comment.fromID)" }).first {
                    if delegate is TopicController {
                        name = "пользователю «\(user.firstName) \(user.lastName)»"
                    } else {
                        name = "\(user.firstNameDat) \(user.lastNameDat)"
                    }
                }
            } else if comment.fromID < 0 {
                if let group = groups.filter({ $0.gid == abs(comment.fromID) }).first {
                    name = "сообществу «\(group.name)»"
                }
            }
            
            let tap = UITapGestureRecognizer()
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            tap.add {
                self.delegate.openProfileController(id: comment.fromID, name: "")
            }
        }
        
        return name
    }
    
    func removeSubviews() {
        for subview in self.subviews {
            if subview.tag == 250 {
                subview.removeFromSuperview()
            }
        }
    }
}
