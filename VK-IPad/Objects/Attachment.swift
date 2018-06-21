//
//  Attachment.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Attachment {
    var type = ""
    var photo: [Photo] = []
    var video: [Video] = []
    var audio: [Audio] = []
    var doc: [Document] = []
    var link: [Link] = []
    var poll: [Poll] = []
    var sticker: [Sticker] = []
    
    init(json: JSON) {
        self.type = json["type"].stringValue
        
        if self.type == "photo" {
            let photo = Photo(json: JSON.null)
            photo.id = json["photo"]["id"].intValue
            photo.albumID = json["photo"]["album_id"].intValue
            photo.ownerID = json["photo"]["owner_id"].intValue
            photo.userID = json["photo"]["user_id"].intValue
            photo.text = json["photo"]["text"].stringValue
            photo.date = json["photo"]["date"].intValue
            photo.width = json["photo"]["width"].intValue
            photo.height = json["photo"]["height"].intValue
            photo.photo75 = json["photo"]["photo_75"].stringValue
            photo.photo130 = json["photo"]["photo_130"].stringValue
            photo.photo604 = json["photo"]["photo_604"].stringValue
            photo.photo807 = json["photo"]["photo_807"].stringValue
            photo.photo1280 = json["photo"]["photo_1280"].stringValue
            photo.photo2560 = json["photo"]["photo_2560"].stringValue
            photo.accessKey = json["photo"]["access_key"].stringValue
            self.photo.append(photo)
        }
        
        if self.type == "video" {
            let video = Video(json: JSON.null)
            video.id = json["video"]["id"].intValue
            video.ownerID = json["video"]["owner_id"].intValue
            video.title = json["video"]["title"].stringValue
            video.description = json["video"]["description"].stringValue
            video.duration = json["video"]["duration"].intValue
            video.photo130 = json["video"]["photo_130"].stringValue
            video.photo320 = json["video"]["photo_320"].stringValue
            video.photo640 = json["video"]["photo_640"].stringValue
            video.photo800 = json["video"]["photo_800"].stringValue
            video.date = json["video"]["date"].intValue
            video.addingDate = json["video"]["adding_date"].intValue
            video.views = json["video"]["views"].intValue
            video.comments = json["video"]["comments"].intValue
            video.player = json["video"]["player"].stringValue
            video.platform = json["video"]["platform"].stringValue
            video.canEdit = json["video"]["can_edit"].intValue
            video.canAdd = json["video"]["can_add"].intValue
            video.isPrivate = json["video"]["is_private"].intValue
            video.accessKey = json["video"]["access_key"].stringValue
            video.processing = json["video"]["processing"].intValue
            video.live = json["video"]["live"].intValue
            video.upcoming = json["video"]["upcoming"].intValue
            self.video.append(video)
        }
        
        if self.type == "doc" {
            let doc = Document(json: JSON.null)
            doc.id = json["doc"]["id"].intValue
            doc.ownerID = json["doc"]["owner_id"].intValue
            doc.title = json["doc"]["title"].stringValue
            doc.size = json["doc"]["size"].intValue
            doc.ext = json["doc"]["ext"].stringValue
            doc.url = json["doc"]["url"].stringValue
            doc.date = json["doc"]["date"].intValue
            doc.type = json["doc"]["type"].intValue
            doc.accessKey = json["doc"]["access_key"].stringValue
            for index in 0...3 {
                let url = json["doc"]["preview"]["photo"]["sizes"][index]["src"].stringValue
                if url != "" {
                    doc.photoURL.append(url)
                }
            }
            doc.videoURL = json["doc"]["preview"]["video"]["src"].stringValue
            doc.width = json["doc"]["preview"]["video"]["width"].intValue
            doc.height = json["doc"]["preview"]["video"]["height"].intValue
            self.doc.append(doc)
        }
        
        if self.type == "audio" {
            let audio = Audio(json: JSON.null)
            audio.id = json["audio"]["id"].intValue
            audio.ownerID = json["audio"]["owner_id"].intValue
            audio.artist = json["audio"]["artist"].stringValue
            audio.title = json["audio"]["title"].stringValue
            audio.duration = json["audio"]["duration"].intValue
            audio.url = json["audio"]["url"].intValue
            audio.albumID = json["audio"]["album_id"].intValue
            audio.accessKey = json["audio"]["access_key"].stringValue
            self.audio.append(audio)
        }
        
        if self.type == "link" {
            let link = Link(json: JSON.null)
            link.url = json["link"]["url"].stringValue
            link.title = json["link"]["title"].stringValue
            link.caption = json["link"]["caption"].stringValue
            link.description = json["link"]["description"].stringValue
            
            let photo = Photo(json: JSON.null)
            photo.id = json["link"]["photo"]["id"].intValue
            photo.albumID = json["link"]["photo"]["album_id"].intValue
            photo.ownerID = json["link"]["photo"]["owner_id"].intValue
            photo.userID = json["link"]["photo"]["user_id"].intValue
            photo.text = json["link"]["photo"]["text"].stringValue
            photo.date = json["link"]["photo"]["date"].intValue
            photo.width = json["link"]["photo"]["width"].intValue
            photo.height = json["link"]["photo"]["height"].intValue
            photo.photo75 = json["link"]["photo"]["photo_75"].stringValue
            photo.photo130 = json["link"]["photo"]["photo_130"].stringValue
            photo.photo604 = json["link"]["photo"]["photo_604"].stringValue
            photo.photo807 = json["link"]["photo"]["photo_807"].stringValue
            photo.photo1280 = json["link"]["photo"]["photo_1280"].stringValue
            photo.photo2560 = json["link"]["photo"]["photo_2560"].stringValue
            link.photo.append(photo)
            
            self.link.append(link)
        }
        
        if self.type == "poll" {
            let poll = Poll(json: JSON.null)
            poll.id = json["poll"]["id"].intValue
            poll.ownerID = json["poll"]["owner_id"].intValue
            poll.created = json["poll"]["created"].intValue
            poll.question = json["poll"]["question"].stringValue
            poll.votes = json["poll"]["votes"].intValue
            poll.answerID = json["poll"]["answer_id"].intValue
            poll.anonymous = json["poll"]["anonymous"].intValue
            
            for index in 0...19 {
                let answers = PollAnswer(json: JSON.null)
                answers.id = json["poll"]["answers"][index]["id"].intValue
                if answers.id > 0 {
                    answers.text = json["poll"]["answers"][index]["text"].stringValue
                    answers.votes = json["poll"]["answers"][index]["votes"].intValue
                    answers.rate = json["poll"]["answers"][index]["rate"].intValue
                    poll.answers.append(answers)
                }
            }
            
            self.poll.append(poll)
        }
        
        if self.type == "sticker" {
            let sticker = Sticker(json: JSON.null)
            sticker.productID = json["sticker"]["product_id"].intValue
            sticker.stickerID = json["sticker"]["id"].intValue
            sticker.url = json["sticker"]["photo_256"].stringValue
            sticker.width = json["sticker"]["width"].intValue
            sticker.height = json["sticker"]["height"].intValue
            self.sticker.append(sticker)
        }
    }
}
