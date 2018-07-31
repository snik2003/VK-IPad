//
//  TopicCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 30.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class TopicCell: UITableViewCell {
    
    var delegate: UIViewController!
    
    var topic: Topic!
    var group: GroupProfile!
    var users: [UserProfile] = []
    
    var indexPath: IndexPath!
    var cell: UITableViewCell!
    var tableView: UITableView!
    var cellWidth: CGFloat = 0
    
    
    let leftInsets: CGFloat = 20
    let topInsets: CGFloat = 10
    
    let avatarHeight: CGFloat = 50
    
    let nameFont = UIFont(name: "Verdana-Bold", size: 15)!
    let titleFont = UIFont(name: "Verdana-Bold", size: 14)!
    let commentFont = UIFont(name: "Verdana", size: 14)!
    let countFont = UIFont(name: "Verdana-Bold", size: 12)!
    let closedFont = UIFont(name: "Verdana-Bold", size: 13)!
    
    func configureCell(calc: Bool) -> CGFloat {
        
        self.removeAllSubviews()
        
        let title = topic.title.prepareTextForPublic()
        let titleLabelSize = self.delegate.getTextSize(text: title, font: titleFont, maxWidth: cellWidth - 2 * leftInsets)
        
        var comment = topic.firstCommentText.prepareTextForPublic()
        if self.delegate is TopicsListController {
            comment = topic.firstCommentText.prepareTextForPublic().replacingOccurrences(of: "\n", with: " ")
        }
        let commentLabelSize = self.delegate.getTextSize(text: comment, font: commentFont, maxWidth: cellWidth - 2 * leftInsets)
        
        if !calc {
            var url = group.photo100
            var name = group.name
            var id = "-\(group.gid)"
            
            let user = users.filter({ $0.uid == "\(topic.createdBy)" })
            if user.count > 0 && user[0].lastName != "Администратор" && user[0].firstName != "Администратор" {
                url = user[0].photo100
                name = "\(user[0].firstName) \(user[0].lastName)"
                id = user[0].uid
            }
            
            let avatarImage = UIImageView()
            avatarImage.tag = 250
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                avatarImage.layer.cornerRadius = 25
                avatarImage.contentMode = .scaleAspectFit
                avatarImage.clipsToBounds = true
            }
            
            avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarHeight, height: avatarHeight)
            self.addSubview(avatarImage)
            
            let avatarTap = UITapGestureRecognizer()
            avatarImage.isUserInteractionEnabled = true
            avatarImage.addGestureRecognizer(avatarTap)
            avatarTap.add {
                if let id = Int(id) {
                    self.delegate.openProfileController(id: id, name: name)
                }
            }
            
            
            let nameLabel = UILabel()
            nameLabel.tag = 250
            nameLabel.text = name
            if topic.isFixed == 1 {
                nameLabel.text = "📌 \(name)"
            }
            nameLabel.textColor = UIColor.black
            nameLabel.font = nameFont
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.3
            
            nameLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 10, width: cellWidth - 3 * leftInsets - avatarHeight, height: 18)
            self.addSubview(nameLabel)
            
            let nameTap = UITapGestureRecognizer()
            nameLabel.isUserInteractionEnabled = true
            nameLabel.addGestureRecognizer(nameTap)
            nameTap.add {
                if let id = Int(id) {
                    self.delegate.openProfileController(id: id, name: name)
                }
            }
            
            
            let createdLabel = UILabel()
            createdLabel.tag = 250
            createdLabel.text = "Дата создания обсуждения: \(topic.created.toStringLastTime())"
            createdLabel.font = UIFont(name: "Verdana", size: 12)!
            createdLabel.adjustsFontSizeToFitWidth = true
            createdLabel.minimumScaleFactor = 0.5
            createdLabel.isEnabled = false
            
            createdLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 28, width: cellWidth - 3 * leftInsets - avatarHeight, height: 17)
            self.addSubview(createdLabel)
            
            let createdTap = UITapGestureRecognizer()
            createdLabel.isUserInteractionEnabled = true
            createdLabel.addGestureRecognizer(createdTap)
            createdTap.add {
                if let id = Int(id) {
                    self.delegate.openProfileController(id: id, name: name)
                }
            }
            
            
            let updatedLabel = UILabel()
            updatedLabel.tag = 250
            updatedLabel.text = "Дата последнего изменения: \(topic.updated.toStringLastTime())"
            updatedLabel.font = UIFont(name: "Verdana", size: 12)!
            updatedLabel.adjustsFontSizeToFitWidth = true
            updatedLabel.minimumScaleFactor = 0.5
            updatedLabel.isEnabled = false
            
            updatedLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 45, width: cellWidth - 3 * leftInsets - avatarHeight, height: 17)
            self.addSubview(updatedLabel)
            
            let updatedTap = UITapGestureRecognizer()
            updatedLabel.isUserInteractionEnabled = true
            updatedLabel.addGestureRecognizer(updatedTap)
            updatedTap.add {
                if let id = Int(id) {
                    self.delegate.openProfileController(id: id, name: name)
                }
            }
        }
        
        var topY: CGFloat = 2 * topInsets + avatarHeight
        
        if !calc {
            let titleLabel = UILabel()
            titleLabel.tag = 250
            titleLabel.text = title
            titleLabel.font = titleFont
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.textColor = vkSingleton.shared.mainColor
            titleLabel.prepareTextForPublish2(delegate, cell: self)
            titleLabel.frame = CGRect(x: leftInsets, y: topY, width: cellWidth - 2 * leftInsets, height: titleLabelSize.height + 5)
            self.addSubview(titleLabel)
        }
        
        topY += titleLabelSize.height + 5
        
        if !calc {
            let commentLabel = UILabel()
            commentLabel.tag = 250
            commentLabel.text = comment
            commentLabel.font = commentFont
            commentLabel.numberOfLines = 0
            commentLabel.prepareTextForPublish2(delegate, cell: self)
            commentLabel.frame = CGRect(x: leftInsets, y: topY, width: commentLabelSize.width, height: commentLabelSize.height + 5)
            self.addSubview(commentLabel)
        }
        
        topY += commentLabelSize.height + 5
        
        if !calc {
            let countLabel = UILabel()
            countLabel.tag = 250
            countLabel.text = topic.commentsCount.messageAdder()
            countLabel.textAlignment = .right
            countLabel.textColor = vkSingleton.shared.mainColor
            countLabel.font = countFont
            countLabel.numberOfLines = 1
            
            countLabel.frame = CGRect(x: 2 * leftInsets, y: topY, width: cellWidth - 4 * leftInsets, height: 20)
            self.addSubview(countLabel)
        }
        
        topY += 20
        
        if topic.isClosed == 1 {
            if !calc {
                let closedLabel = UILabel()
                closedLabel.tag = 250
                closedLabel.text = "Обсуждение закрыто"
                closedLabel.textAlignment = .center
                closedLabel.textColor = UIColor.purple
                closedLabel.font = closedFont
                closedLabel.numberOfLines = 1
                
                closedLabel.frame = CGRect(x: leftInsets, y: topY, width: cellWidth - 2 * leftInsets, height: 30)
                self.addSubview(closedLabel)
            }
            topY += 30
        }
        
        return topY
    }
}
