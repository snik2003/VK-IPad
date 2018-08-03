//
//  AttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class AttachPanel: UIView {

    var delegate: UIViewController!
    
    var comments: [Comment] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var replyID = 0 {
        didSet {
            self.removeFromSuperview()
            self.reconfigure()
        }
    }
    
    var attachArray: [AnyObject] = []
    var attachments = ""
    
    func reconfigure() {
        
        removeSubviews()
        self.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.9)
        
        var height: CGFloat = 0
        
        let width = self.delegate.view.bounds.width
        
        if replyID != 0 {
            let nameLabel = UILabel()
            nameLabel.tag = 250
            nameLabel.text = "Вы отвечаете \(getReplyName(commentID: replyID))"
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
            nameLabel.textColor = vkSingleton.shared.mainColor //UIColor.white
            nameLabel.frame = CGRect(x: 20, y: height, width: width - 40 - 100, height: 40)
            self.addSubview(nameLabel)
            
            let xButton = UIButton()
            xButton.tag = 250
            xButton.setTitle("Отменить", for: .normal)
            xButton.setTitleColor(UIColor.red, for: .normal)
            xButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
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
            xButton.frame = CGRect(x: width - 20 - 100, y: height, width: 100, height: 40)
            self.addSubview(xButton)
            
            height += 40
        }
        
        attachments = ""
        if attachArray.count > 0 {
            for index in 0...attachArray.count-1 {
                let nameLabel = UILabel()
                nameLabel.tag = 250
                nameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
                nameLabel.textColor = vkSingleton.shared.mainColor
                nameLabel.frame = CGRect(x: 20, y: height, width: width - 40 - 100, height: 30)
                self.addSubview(nameLabel)
                
                let xButton = UIButton()
                xButton.tag = 250
                xButton.setTitle("Удалить", for: .normal)
                xButton.setTitleColor(UIColor.red, for: .normal)
                xButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
                xButton.contentHorizontalAlignment = .right
                
                if let video = attachArray[index] as? Video {
                    if attachments != "" {
                        attachments = "\(attachments), "
                    }
                    attachments = "\(attachments)video\(video.ownerID)_\(video.id)"
 
                    nameLabel.text = "Видеозапись «\(video.title)»"
                    
                    xButton.add(for: .touchUpInside) {
                        self.attachArray.remove(at: index)
                        self.removeFromSuperview()
                        self.reconfigure()
                    }
                }
                xButton.frame = CGRect(x: width - 20 - 100, y: height, width: 100, height: 30)
                self.addSubview(xButton)
                
                height += 30
            }
        }
        
        if let controller = delegate as? RecordController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? VideoController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? TopicController {
            controller.commentView.attachCount = attachArray.count
        }
        
        if height > 0 {
            self.frame = CGRect(x: 0, y: 64, width: width, height: height)
            
            self.layer.cornerRadius = 0 //height / 4
            self.layer.borderColor = UIColor.gray.cgColor
            self.layer.borderWidth = 0.5
            self.delegate.view.addSubview(self)
        }
        
        print("attachments = \(attachments)")
    }
    
    func getReplyName(commentID: Int) -> String {
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
