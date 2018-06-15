//
//  RecordCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    var delegate: UIViewController!
    var record: Record!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var cellWidth: CGFloat = 0
    var leftX: CGFloat = 20
    
    let avatarHeight: CGFloat = 50
    let avatarHeight2: CGFloat = 40
    
    let friendsOnlyLabel = UILabel()
    
    let textFont = UIFont(name: "TrebuchetMS", size: 13)!
    let nameFont = UIFont(name: "TrebuchetMS-Bold", size: 14)!
    func configureCell() {
        
        self.removeAllSubviews()
        
        if let record = record {
            var topY: CGFloat = 0
            leftX = 20
            setOnlyFriends()
            
            setHeader(topY: topY, size: avatarHeight, record: record)
            
            topY += 5 + avatarHeight + 5
            topY = setText(text: record.text, topY: topY)
            
            if record.copy.count > 0 {
                for index in 0...record.copy.count-1 {
                    let x1 = topY
                    
                    leftX += 20
                    setHeader(topY: topY, size: avatarHeight2, record: record.copy[index])
                    
                    topY += 5 + avatarHeight2 + 5
                    topY = setText(text: record.copy[index].text, topY: topY)
                    
                    let x2 = topY
                    drawRepostLine(x1, x2)
                }
            }
        }
    }
        
    
    func setOnlyFriends() {
        
        if let record = self.record {
            if record.friendsOnly == 1 {
                let friendsOnlyLabel = UILabel()
                
                friendsOnlyLabel.tag = 250
                friendsOnlyLabel.text = "Запись только друзей!"
                friendsOnlyLabel.textAlignment = .right
                friendsOnlyLabel.font = UIFont(name: "TrebuchetMS", size: 12)!
                friendsOnlyLabel.textColor = UIColor.red
                
                friendsOnlyLabel.frame = CGRect(x: cellWidth - 170, y: 2, width: 150, height: 18)
                
                self.addSubview(friendsOnlyLabel)
            }
        }
    }
    
    func setHeader(topY: CGFloat, size: CGFloat, record: Record) {

        var url = ""
        var name = ""
        
        let avatarImage = UIImageView()
        let nameLabel = UILabel()
        let dateLabel = UILabel()
        
        avatarImage.tag = 250
        nameLabel.tag = 250
        dateLabel.tag = 250
        
        if record.fromID > 0 {
            let user = users.filter({ $0.uid == "\(record.fromID)" })
            if user.count > 0 {
                url = user[0].photo100
                name = "\(user[0].firstName) \(user[0].lastName)"
            }
        } else if record.fromID < 0 {
            let group = groups.filter({ $0.gid == abs(record.fromID) })
            if group.count > 0 {
                url = group[0].photo100
                name = group[0].name
            }
        }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatarImage.image = getCacheImage.outputImage
                avatarImage.layer.borderColor = UIColor.lightGray.cgColor
                avatarImage.layer.borderWidth = 0.6
                avatarImage.layer.cornerRadius = size/2
                avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        nameLabel.text = name
        nameLabel.font = nameFont
        
        dateLabel.text = record.date.toStringLastTime()
        dateLabel.font = UIFont(name: "TrebuchetMS", size: 12)!
        dateLabel.isEnabled = false
        
        avatarImage.frame = CGRect(x: leftX - 10, y: topY + 5, width: size, height: size)
        nameLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY - 20, width: cellWidth - avatarImage.frame.maxX - 20, height: 20)
        dateLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY, width: cellWidth - avatarImage.frame.maxX - 20, height: 16)
        
        self.addSubview(avatarImage)
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
    }
    
    func setText(text: String, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let label = UILabel()
        
        label.tag = 250
        label.text = text
        label.font = textFont
        label.numberOfLines = 0
        label.prepareTextForPublish2(delegate)
        
        let maxWidth = cellWidth - leftX - 20
        var size = delegate.getTextSize(text: label.text!, font: textFont, maxWidth: maxWidth)
        
        if size.height > 0 {
            size.height += 10
        }
        
        label.frame = CGRect(x: leftX, y: topY, width: maxWidth, height: size.height)
        self.addSubview(label)
        
        topY += size.height
        
        return topY
    }
    
    func drawRepostLine(_ x1: CGFloat, _ x2: CGFloat) {
        
        let view = UIView()
        
        view.tag = 250
        view.backgroundColor = vkSingleton.shared.mainColor
        view.frame = CGRect(x: leftX - 20, y: x1, width: 3, height: x2 - x1)
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.2
        view.layer.cornerRadius = 0.5
        view.clipsToBounds = true
        
        self.addSubview(view)
    }
}

extension RecordCell {
    func getRowHeight() -> CGFloat {
        
        var height = 5 + avatarHeight + 5
        var leftX: CGFloat = 20
        
        let maxWidth = cellWidth - leftX - 20
        var size = delegate.getTextSize(text: record.text.prepareTextForPublic(), font: textFont, maxWidth: maxWidth)
        
        if size.height > 0 {
            size.height += 10
        }
        
        height += size.height
        
        if record.copy.count > 0 {
            for index in 0...record.copy.count-1 {
                leftX += 20
            
                height += 5 + avatarHeight2 + 5
                
                let maxWidth2 = cellWidth - leftX - 20
                var size2 = delegate.getTextSize(text: record.copy[index].text.prepareTextForPublic(), font: textFont, maxWidth: maxWidth2)
                
                if size2.height > 0 {
                    size2.height += 10
                }
                
                height += size2.height
            }
        }
        
        return height + 5
    }
}


