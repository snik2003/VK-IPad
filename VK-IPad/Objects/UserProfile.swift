//
//  UserProfile.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserProfile {
    var uid: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var maidenName: String = "" // девичья фамилия
    var sex: Int = 0
    var domain: String = ""
    var relation: Int = 0
    var birthDate: String = ""
    var homeTown: String = ""
    var hasPhoto: Int = 0
    var countryId: String = ""
    var countryName: String = ""
    var cityId: String = ""
    var cityName: String = ""
    var status: String = ""
    var lastSeen: Int = 0
    var platform: Int = 0
    var onlineStatus: Int = 0
    var onlineMobile: Int = 0
    var maxPhotoURL: String = ""
    var maxPhotoOrigURL: String = ""
    var avatarID: String = ""
    var followersCount: Int = 0
    var friendsCount: Int = 0
    var commonFriendsCount: Int = 0
    var groupsCount: Int = 0
    var photosCount: Int = 0
    var videosCount: Int = 0
    var audiosCount: Int = 0
    var pagesCount: Int = 0
    var notesCount: Int = 0
    var deactivated: String = ""
    var universityName: String = ""
    var universityGraduation: Int = 0
    var facultyName: String = ""
    var mobilePhone: String = ""
    var site: String = ""
    var skype: String = ""
    var facebook: String = ""
    var twitter: String = ""
    var instagram: String = ""
    var about: String = "" //  О себе
    var interests: String = "" // Интересы
    var activities: String = "" // Деятельность
    var books: String = "" // Любимые книги
    var games: String = "" // Любимые игры
    var movies: String = "" // Любимые фильмы
    var music: String = "" // Любимая музыка
    var tv: String = "" // Любимые телешоу
    var quotes: String = "" // Любимые цитаты
    var firstNameAbl: String = "" // Имя в предложном падеже (О Ком?)
    var firstNameGen: String = "" // Имя в родительном падеже (Чей?)
    var firstNameDat: String = "" // Имя в дательном падеже (Кому?)
    var firstNameIns: String = "" // Имя в творительном падеже (Кем?)
    var firstNameAcc: String = "" // Имя в винительном падеже (Кому?)
    var lastNameAbl: String = "" // Фамилия в предложном падеже (О Ком?)
    var lastNameGen: String = "" // Фамилия в родительном падеже (Чей?)
    var lastNameDat: String = "" // Фамилия в дательном падеже (Кому?)
    var lastNameIns: String = "" // Фамилия в творительном падеже (Кем?)
    var lastNameAcc: String = "" // Фамилия в винительном падеже (Кому?)
    var canSeeAllPosts: Int = 0
    var canSendFriendRequest: Int = 0
    var canWritePrivateMessage: Int = 0
    var canPost: Int = 0
    var friendStatus: Int = 0
    var isFavorite: Int = 0
    var blacklisted: Int = 0
    var blacklistedByMe: Int = 0
    var cropPhotoURL: String = ""
    var cropX1: Double = 0
    var cropY1: Double = 0
    var cropX2: Double = 0
    var cropY2: Double = 0
    var rectX1: Double = 0
    var rectY1: Double = 0
    var rectX2: Double = 0
    var rectY2: Double = 0
    var photoWidth: Int = 0
    var photoHeight: Int = 0
    var isHiddenFromFeed: Int = 0
    var wallDefault = ""
    var persPolitical = 0
    var persReligion = ""
    var persInspired = ""
    var persPeopleMain = 0
    var persLifeMain = 0
    var persSmoking = 0
    var persAlcohol = 0
    var relatives: [Relatives] = []
    var photo100 = ""
    
    init(json: JSON) {
        self.uid = json["id"].stringValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.maidenName = json["maiden_name"].stringValue
        self.sex = json["sex"].intValue
        self.relation = json["relation"].intValue
        self.domain = json["domain"].stringValue
        self.birthDate = json["bdate"].stringValue
        self.hasPhoto = json["has_photo"].intValue
        self.homeTown = json["home_town"].stringValue
        self.countryId = json["country"]["id"].stringValue
        self.countryName = json["country"]["title"].stringValue
        self.cityId = json["city"]["id"].stringValue
        self.cityName = json["city"]["title"].stringValue
        self.status = json["status"].stringValue
        self.lastSeen = json["last_seen"]["time"].intValue
        self.platform = json["last_seen"]["platform"].intValue
        self.onlineStatus = json["online"].intValue
        self.onlineMobile = json["online_mobile"].intValue
        self.maxPhotoURL = json["photo_max"].stringValue
        self.maxPhotoOrigURL = json["photo_max_orig"].stringValue
        self.avatarID = json["photo_id"].stringValue
        self.followersCount = json["counters"]["followers"].intValue
        self.friendsCount = json["counters"]["friends"].intValue
        self.commonFriendsCount = json["counters"]["mutual_friends"].intValue
        self.groupsCount = json["counters"]["groups"].intValue
        self.photosCount = json["counters"]["photos"].intValue
        self.videosCount = json["counters"]["videos"].intValue
        self.audiosCount = json["counters"]["audios"].intValue
        self.pagesCount = json["counters"]["pages"].intValue
        self.notesCount = json["counters"]["notes"].intValue
        self.deactivated = json["deactivated"].stringValue
        self.universityName = json["university_name"].stringValue
        self.universityGraduation = json["graduation"].intValue
        self.facultyName = json["faculty_name"].stringValue
        self.mobilePhone = json["mobile_phone"].stringValue
        self.site = json["site"].stringValue
        self.skype = json["skype"].stringValue
        self.facebook = json["facebook"].stringValue
        self.twitter = json["twitter"].stringValue
        self.instagram = json["instagram"].stringValue
        self.about = json["about"].stringValue
        self.interests = json["interests"].stringValue
        self.activities = json["activities"].stringValue
        self.books = json["books"].stringValue
        self.games = json["games"].stringValue
        self.movies = json["movies"].stringValue
        self.music = json["music"].stringValue
        self.tv = json["tv"].stringValue
        self.quotes = json["quotes"].stringValue
        self.firstNameAbl = json["first_name_abl"].stringValue
        self.firstNameGen = json["first_name_gen"].stringValue
        self.firstNameDat = json["first_name_dat"].stringValue
        self.firstNameIns = json["first_name_ins"].stringValue
        self.firstNameAcc = json["first_name_acc"].stringValue
        self.lastNameAbl = json["last_name_abl"].stringValue
        self.lastNameGen = json["last_name_gen"].stringValue
        self.lastNameDat = json["last_name_dat"].stringValue
        self.lastNameIns = json["last_name_ins"].stringValue
        self.lastNameAcc = json["last_name_acc"].stringValue
        self.canSeeAllPosts = json["can_see_all_posts"].intValue
        self.canSendFriendRequest = json["can_send_friend_request"].intValue
        self.canWritePrivateMessage = json["can_write_private_message"].intValue
        self.canPost = json["can_post"].intValue
        self.friendStatus = json["friend_status"].intValue
        self.isFavorite = json["is_favorite"].intValue
        self.blacklisted = json["blacklisted"].intValue
        self.blacklistedByMe = json["blacklisted_by_me"].intValue
        self.cropX1 = json["crop_photo"]["crop"]["x"].doubleValue
        self.cropY1 = json["crop_photo"]["crop"]["y"].doubleValue
        self.cropX2 = json["crop_photo"]["crop"]["x2"].doubleValue
        self.cropY2 = json["crop_photo"]["crop"]["y2"].doubleValue
        self.rectX1 = json["crop_photo"]["rect"]["x"].doubleValue
        self.rectY1 = json["crop_photo"]["rect"]["y"].doubleValue
        self.rectX2 = json["crop_photo"]["rect"]["x2"].doubleValue
        self.rectY2 = json["crop_photo"]["rect"]["y2"].doubleValue
        self.photoWidth = json["crop_photo"]["photo"]["width"].intValue
        self.photoHeight = json["crop_photo"]["photo"]["height"].intValue
        self.isHiddenFromFeed = json["is_hidden_from_feed"].intValue
        self.wallDefault = json["wall_default"].stringValue
        self.photo100 = json["photo_100"].stringValue
        
        self.cropPhotoURL = json["crop_photo"]["photo"]["photo_1280"].stringValue
        if self.cropPhotoURL == "" {
            self.cropPhotoURL = json["crop_photo"]["photo"]["photo_807"].stringValue
            if self.cropPhotoURL == "" {
                self.cropPhotoURL = json["crop_photo"]["photo"]["photo_604"].stringValue
                if self.cropPhotoURL == "" {
                    self.cropPhotoURL = json["crop_photo"]["photo"]["photo_130"].stringValue
                }
            }
        }
        self.persPolitical = json["personal"]["political"].intValue
        self.persReligion = json["personal"]["religion"].stringValue
        self.persInspired = json["personal"]["inspired_by"].stringValue
        self.persPeopleMain = json["personal"]["people_main"].intValue
        self.persLifeMain = json["personal"]["life_main"].intValue
        self.persSmoking = json["personal"]["smoking"].intValue
        self.persAlcohol = json["personal"]["alcohol"].intValue
        
        for index in 0...19 {
            var rel = Relatives()
            rel.id = json["relatives"][index]["id"].intValue
            rel.name = json["relatives"][index]["name"].stringValue
            rel.type = json["relatives"][index]["type"].stringValue
            if rel.id > 0 {
                self.relatives.append(rel)
            }
        }
    }
}

struct Relatives {
    var id = 0
    var name = ""
    var type = ""
}

extension UserProfile {
    
    var familyStatus: String {
        switch relation {
        case 1:
            if sex == 1 {
                return "не замужем"
            } else {
                return "не женат"
            }
        case 2:
            if sex == 1 {
                return "есть друг"
            } else {
                return "есть подруга"
            }
        case 3:
            if sex == 1 {
                return "помолвлена"
            } else {
                return "помолвлен"
            }
        case 4:
            if sex == 1 {
                return "замужем"
            } else {
                return "женат"
            }
        case 5:
            return "всё сложно"
        case 6:
            return "в активном поиске"
        case 7:
            if sex == 1 {
                return "влюблена"
            } else {
                return "влюблен"
            }
        case 8:
            return "в гражданском браке"
        default:
            return ""
        }
    }
    
    var politicalConviction: String {
        switch persPolitical {
        case 1:
            return "коммунистические"
        case 2:
            return "социалистические"
        case 3:
            return "умеренные"
        case 4:
            return "либеральные"
        case 5:
            return "консервативные"
        case 6:
            return "монархические"
        case 7:
            return "ультраконсервативные"
        case 8:
            return "индифферентные"
        case 9:
            return "либертарианские"
        default:
            return ""
        }
    }
    
    var mainInPeople: String {
        switch persPeopleMain {
        case 1:
            return "ум и креативность"
        case 2:
            return "доброта и честность"
        case 3:
            return "красота и здоровье"
        case 4:
            return "власть и богатство"
        case 5:
            return "смелость и упорство"
        case 6:
            return "юмор и жизнелюбие"
        default:
            return ""
        }
    }
    
    var mainInLife: String {
        switch persLifeMain {
        case 1:
            return "семья и дети"
        case 2:
            return "карьера и деньги"
        case 3:
            return "развлечения и отдых"
        case 4:
            return "наука и исследования"
        case 5:
            return "совершенствование мира"
        case 6:
            return "саморазвитие"
        case 7:
            return "красота и искусство"
        case 8:
            return "слава и влияние"
        default:
            return ""
        }
    }
    
    var smokingRelation: String {
        switch persSmoking {
        case 1:
            return "резко негативное"
        case 2:
            return "негативное"
        case 3:
            return "компромиссное"
        case 4:
            return "нейтральное"
        case 5:
            return "положительное"
        default:
            return ""
        }
    }
    
    var alcoholRelation: String {
        switch persAlcohol {
        case 1:
            return "резко негативное"
        case 2:
            return "негативное"
        case 3:
            return "компромиссное"
        case 4:
            return "нейтральное"
        case 5:
            return "положительное"
        default:
            return ""
        }
    }
    
    func familyConnection(relative: Relatives) -> String {
        switch relative.type {
        case "child":
            if sex == 1 {
                return "дочь"
            }
            return "сын"
        case "sibling":
            if sex == 1 {
                return "сестра"
            }
            return "брат"
        case "parent":
            if sex == 1 {
                return "мама"
            }
            return "папа"
        case "grandparent":
            if sex == 1 {
                return "бабушка"
            }
            return "дедушка"
        case "grandchild":
            if sex == 1 {
                return "внучка"
            }
            return "внук"
        default:
            return ""
        }
    }
    
    var relativesList: String {
        var list = ""
        for rel in relatives {
            if rel.id != 0 {
                if list != "" {
                    list = "\(list),"
                }
                list = "\(list)\(rel.id)"
            }
        }
        return list
    }
    
    func reportMenu(delegate: UIViewController) {
        let alertController = UIAlertController(title: "Жалоба на пользователя", message: "Введите комментарий и укажите тип жалобы", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Комментарий к жалобе"
            textField.font = UIFont(name: "Verdana", size: 14)
            textField.layer.borderColor = vkSingleton.shared.mainColor.cgColor
            textField.layer.cornerRadius = 4
            textField.resignFirstResponder()
        })
        
        let action1 = UIAlertAction(title: "Порнография", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportUser(delegate: delegate, type: "porn", comment: yourComment)
            } else {
                self.reportUser(delegate: delegate, type: "porn", comment: "")
            }
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Рассылка спама", style: .default) { action in
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportUser(delegate: delegate, type: "spam", comment: yourComment)
            } else {
                self.reportUser(delegate: delegate, type: "spam", comment: "")
            }
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Оскорбительное поведение", style: .default) { action in
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportUser(delegate: delegate, type: "insult", comment: yourComment)
            } else {
                self.reportUser(delegate: delegate, type: "insult", comment: "")
            }
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Реклама, засоряющая поиск", style: .default) { action in
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportUser(delegate: delegate, type: "advertisment", comment: yourComment)
            } else {
                self.reportUser(delegate: delegate, type: "advertisment", comment: "")
            }
        }
        alertController.addAction(action4)
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = delegate.view.bounds
            popoverController.sourceView = delegate.view
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        delegate.present(alertController, animated: true)
    }
    
    func reportUser(delegate: UIViewController, type: String, comment: String) {
        
        let url = "/method/users.report"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_id": self.uid,
            "type": type,
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
                delegate.showSuccessMessage(title: "Жалоба на пользователя", msg: "Ваша жалоба на пользователя успешно отправлена.")
            } else {
                delegate.showErrorMessage(title: "Жалоба на пользователя", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
}
