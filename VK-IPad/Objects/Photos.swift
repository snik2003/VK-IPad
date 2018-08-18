//
//  Photos.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class Photo {
    var id = 0
    var albumID = 0
    var ownerID = 0
    var userID = 0
    var text: String = ""
    var date: Int = 0
    var width: Int = 0
    var height: Int = 0
    var photo75 = ""
    var photo130 = ""
    var photo604 = ""
    var photo807 = ""
    var photo1280 = ""
    var photo2560 = ""
    var accessKey = ""
    
    var commentsCount = 0
    var canComment = 0
    var likesCount = 0
    var userLikes = 0
    var tagsCount = 0
    var userCanRepost = 0
    var repostCount = 0
    var userReposted = 0
    
    var isSelected = false
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.albumID = json["album_id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.userID = json["user_id"].intValue
        self.text = json["text"].stringValue
        self.date = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photo75 = json["photo_75"].stringValue
        self.photo130 = json["photo_130"].stringValue
        self.photo604 = json["photo_604"].stringValue
        self.photo807 = json["photo_807"].stringValue
        self.photo1280 = json["photo_1280"].stringValue
        self.photo2560 = json["photo_2560"].stringValue
        self.accessKey = json["access_key"].stringValue
        
        self.canComment = json["can_comment"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.userCanRepost = json["can_repost"].intValue
        self.repostCount = json["reposts"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
    }
}

extension Photo {
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        if lhs.id == rhs.id && lhs.ownerID == rhs.ownerID {
            return true
        }
        return false
    }
    
    var title: String {
        var title = ""
        
        let str1 = self.text.prepareTextForPublic().replacingOccurrences(of: "\n", with: " ").components(separatedBy: [".", "!", "?", "\n"])
        
        if str1[0] != "" {
            title = "«\(str1[0].prefix(50))»"
        }
        
        return title
    }
    
    func copyToSaveAlbum(delegate: UIViewController) {
        
        let url = "/method/photos.copy"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(self.ownerID)",
            "photo_id": "\(self.id)",
            "access_key": self.accessKey,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                delegate.showSuccessMessage(title: "Сохранение фотографии", msg: "Фотография успешно скопирована в альбом «Сохраненные фотографии».")
                
            } else {
                delegate.showErrorMessage(title: "Сохранение фотографии", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func saveToDevice(delegate: UIViewController) {
        
        var url = self.photo2560
        if url == "" {
            url = self.photo1280
            if url == "" {
                url = self.photo807
                if url == "" {
                    url = self.photo604
                }
            }
        }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            let image = getCacheImage.outputImage
            OperationQueue.main.addOperation {
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            }
        }
        OperationQueue().addOperation(getCacheImage)
        delegate.showSuccessMessage(title: "Сохранение фотографии", msg: "Фотография успешно сохранена на ваше устройство.")
    }
    
    func deleteFromSite(delegate: UIViewController) {
        
        let url = "/method/photos.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(self.ownerID)",
            "photo_id": "\(self.id)",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    delegate.navigationController?.popViewController(animated: true)
                }
                
                delegate.showSuccessMessage(title: "Удаление фотографии", msg: "Удаление фотографии успешно завершено. Для завершения обновите информацию на экране.")
            } else {
                delegate.showErrorMessage(title: "Удаление фотографии", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func reportMenu(delegate: UIViewController) {
        let alertController = UIAlertController(title: "Жалоба на фотографию", message: "Введите комментарий и укажите тип жалобы", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Комментарий к жалобе"
            textField.font = UIFont(name: "Verdana", size: 14)
            textField.layer.borderColor = vkSingleton.shared.mainColor.cgColor
            textField.layer.cornerRadius = 4
            textField.resignFirstResponder()
        })
        
        let action1 = UIAlertAction(title: "Это спам", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 0, comment: yourComment)
            }
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Детская порнография", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 1, comment: yourComment)
            }
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Экстремизм", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 2, comment: yourComment)
            }
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Насилие", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 3, comment: yourComment)
            }
        }
        alertController.addAction(action4)
        
        let action5 = UIAlertAction(title: "Пропаганда наркотиков", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 4, comment: yourComment)
            }
        }
        alertController.addAction(action5)
        
        let action6 = UIAlertAction(title: "Материал для взрослых", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 5, comment: yourComment)
            }
        }
        alertController.addAction(action6)
        
        let action7 = UIAlertAction(title: "Оскорбление", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPhoto(delegate: delegate, reason: 6, comment: yourComment)
            }
        }
        alertController.addAction(action7)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = delegate.view.bounds
            popoverController.sourceView = delegate.view
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        delegate.present(alertController, animated: true)
    }
    
    func reportPhoto(delegate: UIViewController, reason: Int, comment: String) {
        
        let url = "/method/photos.report"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(self.ownerID)",
            "video_id": "\(self.id)",
            "reason": "\(reason)",
            "comment": comment,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                delegate.showSuccessMessage(title: "Жалоба на фотографию", msg: "Ваша жалоба на фотографию успешно отправлена в администрацию сайта.")
            } else {
                delegate.showErrorMessage(title: "Жалоба на фотографию", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
}
