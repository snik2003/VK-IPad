//
//  Video.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Video {
    var id = 0
    var ownerID = 0
    var title = ""
    var description = ""
    var duration = 0
    var photo130 = ""
    var photo320 = ""
    var photo640 = ""
    var photo800 = ""
    var date = 0
    var addingDate = 0
    var views = 0
    var comments = 0
    var player = ""
    var platform = ""
    var canEdit = 0
    var canAdd = 0
    var isPrivate = 0
    var accessKey = ""
    var processing = 0
    var live = 0
    var upcoming = 0

    var userLikes = 0
    var countLikes = 0
    var canComment = 0
    var userReposted = 0
    var countReposts = 0
    
    var isSelected = false
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.duration = json["duration"].intValue
        self.photo130 = json["photo_130"].stringValue
        self.photo320 = json["photo_320"].stringValue
        self.photo640 = json["photo_640"].stringValue
        self.photo800 = json["photo_800"].stringValue
        self.date = json["date"].intValue
        self.addingDate = json["adding_date"].intValue
        self.views = json["views"].intValue
        self.comments = json["comments"].intValue
        self.player = json["player"].stringValue
        self.platform = json["platform"].stringValue
        self.canEdit = json["can_edit"].intValue
        self.canAdd = json["can_add"].intValue
        self.isPrivate = json["is_private"].intValue
        self.accessKey = json["access_key"].stringValue
        self.processing = json["processing"].intValue
        self.live = json["live"].intValue
        self.upcoming = json["upcoming"].intValue
        
        self.canComment = json["can_comment"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
        self.countReposts = json["reposts"]["count"].intValue
    }
}

extension Video: Equatable {
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        if lhs.id == rhs.id && lhs.ownerID == rhs.ownerID {
            return true
        }
        return false
    }
    
    func addToFaveVideos(delegate: UIViewController) {
        
        let url = "/method/video.add"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "target_id": vkSingleton.shared.userID,
            "owner_id": "\(ownerID)",
            "video_id": "\(id)",
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
                delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись «\(self.title)» успешно добавлена в раздел «Мои видеозаписи».\n")
            } else {
                if error.errorCode == 800 {
                    delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nЭта видеозапись уже ранее была добавлена в раздел «Мои видеозаписи».\n")
                } else if error.errorCode == 204 {
                    delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nОшибка. Нет доступа.\n")
                } else {
                    delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteFromFaveVideos(delegate: UIViewController) {
        
        let url = "/method/video.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "target_id": vkSingleton.shared.userID,
            "owner_id": "\(ownerID)",
            "video_id": "\(id)",
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
                delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись «\(self.title)» успешно удалена из раздела «Мои видеозаписи».\n")
            } else {
                delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteFromSite(delegate: UIViewController) {
        
        let url = "/method/video.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "photo_id": "\(id)",
            "owner_id": "\(ownerID)",
            "target_id": "\(ownerID)",
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
                
                delegate.showSuccessMessage(title: "Удаление видеозаписи", msg: "Удаление видеозаписи успешно завершено. Для завершения обновите информацию на экране.")
            } else {
                delegate.showErrorMessage(title: "Удаление видеозаписи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
}
