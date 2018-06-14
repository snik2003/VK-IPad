//
//  Label.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

extension UILabel {
    func setOnlineMobileStatus(text: String, platform: Int) {
        let attachment = NSTextAttachment()
        
        if platform == 2 || platform == 3 {
            attachment.image = UIImage(named: "iphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
        } else if platform == 4 {
            attachment.image = UIImage(named: "android")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
        } else {
            attachment.image = UIImage(named: "onlinemobile")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: -5, y: -5, width: 20, height: 20)
        }
        
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        
        let mutableAttributedString = NSMutableAttributedString()
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        mutableAttributedString.append(attachmentStr)
        
        let range2 = NSMakeRange(textString.length-1, attachmentStr.length);
        
        mutableAttributedString.setAttributes([NSAttributedStringKey.foregroundColor: self.tintColor], range: range2)
        
        self.attributedText = mutableAttributedString
    }
    
    func setPlatformStatus(text: String, platform: Int, online: Int) {
        let attachment = NSTextAttachment()
        
        if platform == 2 || platform == 3 {
            attachment.image = UIImage(named: "iphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -2, width: 15, height: 15)
        } else if platform == 4 {
            attachment.image = UIImage(named: "android")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -4, width: 15, height: 15)
        } else {
            attachment.image = UIImage(named: "onlinemobile")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 5, y: -6, width: 20, height: 20)
        }
        
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        let mutableAttributedString = NSMutableAttributedString(string: " ")
        mutableAttributedString.append(attachmentStr)
        
        if online == 1 {
            let range2 = NSMakeRange(0, attachmentStr.length);
            
            mutableAttributedString.setAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], range: range2)
        }
        
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        
        self.attributedText = mutableAttributedString
    }
    
    func setSourceOfRecord(text: String, source: String, delegate: UIViewController) {
        let attachment = NSTextAttachment()
        
        if source == "iphone" || source == "ipad" {
            attachment.image = UIImage(named: "iphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -2, width: 15, height: 15)
        } else if source == "android" {
            attachment.image = UIImage(named: "android")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "wphone" {
            attachment.image = UIImage(named: "wphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "instagram" {
            attachment.image = UIImage(named: "instagram2")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "facebook" {
            attachment.image = UIImage(named: "facebook2")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "twitter" {
            attachment.image = UIImage(named: "twitter2")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "windows" {
            attachment.image = UIImage(named: "windows")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else {
            if vkSingleton.shared.userID == "357365563" {
                delegate.showInfoMessage(title: "Источник записи", msg: "Неопознанный источник записи: \(source)")
            }
        }
        
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        let mutableAttributedString = NSMutableAttributedString(string: " ")
        mutableAttributedString.append(attachmentStr)
        
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        
        self.attributedText = mutableAttributedString
    }
}
