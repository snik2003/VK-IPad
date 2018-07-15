//
//  NotificationCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 12.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    var delegate: NotificationController!
    
    var not: Notification!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var indexPath: IndexPath!
    var cell: UITableViewCell!
    var tableView: UITableView!
    
    var cellWidth: CGFloat = 0
    
    var avatarHeight: CGFloat = 60
    var smallAvatarHeight: CGFloat = 30
    var leftInsets: CGFloat = 10
    var topInsets: CGFloat = 10
    
    var textFont = UIFont(name: "Verdana", size: 15)!
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        var notText = ""
        
        var notID = 0
        var url = ""
        var name = ""
        var sex = -1
        var smallAvatarName = "error"
        
        if not.feedback.count > 0, let row = indexPath?.row {
            notID = not.feedback[row].fromID
            if not.feedback[row].fromID > 0 {
                let user = users.filter({ $0.uid == "\(not.feedback[row].fromID)" })
                if user.count > 0 {
                    url = user[0].photo100
                    sex = user[0].sex
                    name = "\(user[0].firstName) \(user[0].lastName)"
                }
            } else {
                let group = groups.filter({ $0.gid == abs(not.feedback[row].fromID) })
                if group.count > 0 {
                    url = group[0].photo100
                    name = group[0].name
                }
            }
        }
        
        if not.type == "follow" || not.type == "friend_accepted" {
            smallAvatarName = "not_plus"
            
            if not.type == "follow" {
                if sex == 1 {
                    notText = "\(name) подписалась на Вас"
                } else {
                    notText = "\(name) подписался на Вас"
                }
            }
            
            if not.type == "friend_accepted" {
                if sex == 1 {
                    notText = "\(name) приняла вашу заявку в друзья"
                } else {
                    notText = "\(name) принял вашу заявку в друзья"
                }
            }
        }
        
        if not.type == "comment_post" || not.type == "comment_photo" || not.type == "comment_video" || not.type == "reply_comment" || not.type == "reply_comment_photo" || not.type == "reply_comment_video" {
            smallAvatarName = "not_comment"
        }
        
        if not.type == "like_post" || not.type == "like_comment" || not.type == "like_photo" || not.type == "like_video" || not.type == "like_comment_photo" || not.type == "like_comment_video" || not.type == "like_comment_topic" {
            smallAvatarName = "not_like"
            
            if not.type == "like_post" {
                if sex == 1 {
                    notText = "\(name) оценила вашу запись" //\(nameRecord)"
                } else {
                    notText = "\(name) оценил вашу запись" //\(nameRecord)"
                }
            }
            
            if not.type == "like_photo" {
                if sex == 1 {
                    notText = "\(name) оценила вашу фотографию \(getParentCommentText())"
                } else {
                    notText = "\(name) оценил вашу фотографию \(getParentCommentText())"
                }
            }
            
            if not.type == "like_video" {
                if sex == 1 {
                    notText = "\(name) оценила вашу видеозапись \(getParentCommentText())"
                } else {
                    notText = "\(name) оценил вашу видеозапись \(getParentCommentText())"
                }
            }
            
            if not.type == "like_comment" {
                if sex == 1 {
                    notText = "\(name) оценила ваш комментарий к записи\n\n\(getParentCommentText())"
                } else {
                    notText = "\(name) оценил ваш комментарий к записи\n\n\(getParentCommentText())"
                }
            }
            
            if not.type == "like_comment_photo" {
                if sex == 1 {
                    notText = "\(name) оценила ваш комментарий к фотографии\n\n\(getParentCommentText())"
                } else {
                    notText = "\(name) оценил ваш комментарий к фотографии\n\n\(getParentCommentText())"
                }
            }
            
            if not.type == "like_comment_video" {
                if sex == 1 {
                    notText = "\(name) оценила ваш комментарий к видеозаписи\n\n\(getParentCommentText())"
                } else {
                    notText = "\(name) оценил ваш комментарий к видеозаписи\n\n\(getParentCommentText())"
                }
            }
        }
        
        if not.type == "copy_post" || not.type == "copy_photo" || not.type == "copy_video" {
            smallAvatarName = "not_repost"
            
            if not.type == "copy_post" {
                if sex == -1 {
                    notText = "Сообщество \(name) поделилось вашей записью на своей стене"
                    //notText = "Сообщество \(name) поделилось вашей записью \(nameRecord)на своей стене"
                } else if sex == 1 {
                    notText = "\(name) поделилась вашей записью на своей стене"
                    //notText = "\(name) поделилась вашей записью \(nameRecord)на своей стене"
                } else {
                    notText = "\(name) поделился вашей записью на своей стене"
                    //notText = "\(name) поделился вашей записью \(nameRecord)на своей стене"
                }
            }
            
            if not.type == "copy_photo" {
                if sex == -1 {
                    notText = "Сообщество \(name) поделилось вашей фотографией \(getPhotoText())на своей стене"
                } else if sex == 1 {
                    notText = "\(name) поделилась вашей фотографией \(getPhotoText())на своей стене"
                } else {
                    notText = "\(name) поделился вашей фотографией \(getPhotoText())на своей стене"
                }
            }
            
            if not.type == "copy_video" {
                if sex == -1 {
                    notText = "Сообщество \(name) поделилось вашей видеозаписью \(getVideoName())на своей стене"
                } else if sex == 1 {
                    notText = "\(name) поделилась вашей видеозаписью \(getVideoName())на своей стене"
                } else {
                    notText = "\(name) поделился вашей видеозаписью \(getVideoName())на своей стене"
                }
            }
        }
        
        if not.type == "mention" || not.type == "mention_comments" || not.type == "mention_comment_photo" || not.type == "mention_comment_video" {
            smallAvatarName = "not_mention"
        }
        
        let avatarImage = UIImageView()
        let smallImage = UIImageView()
        avatarImage.tag = 250
        smallImage.tag = 250
    
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            avatarImage.layer.cornerRadius = 29
            avatarImage.clipsToBounds = true
            smallImage.image = UIImage(named: smallAvatarName)
            smallImage.layer.cornerRadius = 15
            smallImage.layer.borderColor = UIColor.white.cgColor
            smallImage.layer.borderWidth = 3.0
            smallImage.clipsToBounds = true
        }
        
        avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarHeight, height: avatarHeight)
        
        smallImage.frame = CGRect(x: 2 * leftInsets + avatarHeight - smallAvatarHeight, y: topInsets + avatarHeight - smallAvatarHeight, width: smallAvatarHeight, height: smallAvatarHeight)
        
        let tapAvatar1 = UITapGestureRecognizer()
        avatarImage.isUserInteractionEnabled = true
        tapAvatar1.add {
            self.delegate.openProfileController(id: notID, name: name)
        }
        avatarImage.addGestureRecognizer(tapAvatar1)
        
        let tapAvatar2 = UITapGestureRecognizer()
        smallImage.isUserInteractionEnabled = true
        tapAvatar2.add {
            self.delegate.openProfileController(id: notID, name: name)
        }
        smallImage.addGestureRecognizer(tapAvatar2)
        
        self.addSubview(avatarImage)
        self.addSubview(smallImage)
        
        let label = UILabel()
        label.tag = 250
        if notText != "" {
            label.text = notText
        } else {
            label.text = not.type
        }
        label.font = textFont
        label.numberOfLines = 0
        
        var size = self.delegate.getTextSize(text: label.text!, font: textFont, maxWidth: cellWidth - 3 * leftInsets - avatarHeight)
        if size.height < avatarHeight {
            size.height = avatarHeight
        }
        
        label.frame = CGRect(x: 3 * leftInsets + avatarHeight, y: topInsets, width: size.width, height: size.height)
        self.addSubview(label)
    }
    
    func getRowHeight() -> CGFloat {
        
        var height: CGFloat = 0
        
        height = 2 * topInsets + avatarHeight
        
        return height
    }
    
    func getParentCommentText() -> String {
        
        var str = ""
        if let comment = not.parent.comment {
            if comment.text != "" {
                str = "\"\(comment.text.prepareTextForPublic())\""
            }
        }
        
        return str
    }
    
    func getPhotoText() -> String {
        
        var str = ""
        if let photo = not.parent.photo {
            print("text = \(photo.text)")
            if photo.text != "" {
                str = "\"\(photo.text.prepareTextForPublic())\" "
            }
        }
        
        return str
    }
    
    func getVideoName() -> String {
        
        var str = ""
        if let video = not.parent.video {
            if video.title != "" {
                str = "\"\(video.title.prepareTextForPublic())\" "
            }
        }
        
        return str
    }
}
