//
//  MessageView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 27.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class MessageView: UIView {

    private struct Constants {
        static let bodyFont = UIFont(name: "Verdana", size: 15)!
        static let dateFont = UIFont(name: "Verdana", size: 12)!
        
        static let inBackColor = UIColor(red: 244/255, green: 223/255, blue: 200/255, alpha: 1)
        static let outBackColor = UIColor(red: 200/255, green: 200/255, blue: 238/255, alpha: 1)
    }
    
    var delegate: DialogController!
    var cell: MessageCell!
    var indexPath: IndexPath!
    var dialog: Dialog!
    
    var maxWidth: CGFloat = 0
    
    let bodyView = UIView()
    
    func configureView(calcHeight: Bool) -> CGFloat {
        
        self.backgroundColor = UIColor.clear
        
        var height: CGFloat = 0
        let width: CGFloat = delegate.width
        
        if !calcHeight {
            var avatarURL = ""
            var avatarName = ""
            if dialog.fromID > 0 {
                let users = delegate.users.filter({ $0.uid == "\(dialog.fromID)" })
                if users.count > 0 {
                    avatarURL = users[0].maxPhotoOrigURL
                    avatarName = "\(users[0].firstName) \(users[0].lastName)"
                }
            } else if dialog.fromID < 0 {
                let groups = delegate.groups.filter({ $0.gid == abs(dialog.fromID) })
                if groups.count > 0 {
                    avatarURL = groups[0].photo100
                    avatarName = groups[0].name
                }
            }
            let avatarImage = UIImageView()
            avatarImage.tag = 250
            let getCacheImage = GetCacheImage(url: avatarURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: delegate.tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                avatarImage.layer.cornerRadius = 20
                avatarImage.clipsToBounds = true
                avatarImage.contentMode = .scaleAspectFill
                avatarImage.layer.borderColor = UIColor.lightGray.cgColor
                avatarImage.layer.borderWidth = 0.5
            }
            
            if dialog.out == 0 {
                avatarImage.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
            } else {
                avatarImage.frame = CGRect(x: maxWidth - 10 - 40, y: 0, width: 40, height: 40)
            }
            self.addSubview(avatarImage)
            
            let tapAvatar = UITapGestureRecognizer()
            tapAvatar.add {
                if self.delegate.mode == .dialog {
                    self.delegate.openProfileController(id: self.dialog.fromID, name: avatarName)
                }
            }
            avatarImage.isUserInteractionEnabled = true
            avatarImage.addGestureRecognizer(tapAvatar)
        }
        
        let size = delegate.getTextSize(text: dialog.body.prepareTextForPublic(), font: Constants.bodyFont, maxWidth: maxWidth)
        
        if !calcHeight && size.height > 0 {
            let label = UILabel()
            label.text = dialog.body
            label.font = Constants.bodyFont
            label.numberOfLines = 0
            label.prepareTextForPublish2(delegate, cell: cell)
            label.frame = CGRect(x: 10, y: 0, width: size.width, height: size.height + 10)
            bodyView.addSubview(label)
            
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 60
                bodyView.backgroundColor = Constants.inBackColor
            } else {
                leftX = maxWidth - 60 - (label.frame.width + 20)
                bodyView.backgroundColor = Constants.outBackColor
            }
            bodyView.frame = CGRect(x: leftX, y: height, width: label.frame.width + 20, height: label.frame.height)
            bodyView.configureMessageView()
            self.addSubview(bodyView)
        }
        
        if size.height > 0 {
            height += size.height + 12
        }
        
        let aView = AttachmentsView()
        aView.tag = 250
        aView.delegate = self.delegate
        let aHeight = aView.configureAttachView(attaches: dialog.attachments, maxSize: maxWidth - 60, getRow: calcHeight)
        
        if !calcHeight && aHeight > 0 {
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 60
                aView.configureViewWithPhotos(color: Constants.inBackColor)
            } else {
                leftX = maxWidth - 60 - aView.frame.width
                aView.configureViewWithPhotos(color: Constants.outBackColor)
            }
            aView.frame = CGRect(x: leftX, y: height, width: aView.frame.width, height: aHeight)
            aView.clipsToBounds = true
            self.addSubview(aView)
        }
        
        height += aHeight
        
        if !calcHeight {
            let label = UILabel()
            label.text = dialog.date.toStringLastTime()
            label.font = Constants.dateFont
            label.numberOfLines = 1
            label.isEnabled = false
            if dialog.out == 0 {
                label.frame = CGRect(x: 63, y: height, width: maxWidth - 66, height: 20)
                label.textAlignment = .left
            } else {
                label.frame = CGRect(x: 3, y: height, width: maxWidth - 66, height: 20)
                label.textAlignment = .right
            }
            self.addSubview(label)
        }
        
        height += 20
        
        if !calcHeight {
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 0
            } else {
                leftX = width - maxWidth
            }
            self.frame = CGRect(x: leftX, y: 12, width: maxWidth, height: height)
            cell.addSubview(self)
        }
        
        height = max(height,60)
        return height + 24
    }
}

extension UIView {
    
    func configureMessageView() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0.6
        self.layer.cornerRadius = 6
    }
    
    func configureViewWithPhotos(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 4
        self.layer.cornerRadius = 6
    }
}
