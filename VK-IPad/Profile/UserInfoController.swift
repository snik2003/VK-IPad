//
//  UserInfoController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 25.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInfoController: UITableViewController {

    var user: UserProfile!
    var relatives: [UserProfile] = []
    
    var width: CGFloat = 0
    
    var countBasicInfoSection = 0
    var countContactInfoSection = 0
    var countPersonalInfoSection = 0
    var countLifePositionSection = 0
    
    var basicInfoSection = [InfoInProfile]()
    var contactInfoSection = [InfoInProfile]()
    var personalInfoSection = [InfoInProfile]()
    var lifePositionSection = [InfoInProfile]()
    var relativesSection = [InfoInProfile]()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
        dateFormatter.dateFormat = "dd MMMM yyyyг. в HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RelativeCell.self, forCellReuseIdentifier: "relativeCell")
        tableView.register(PersonalInfoCell.self, forCellReuseIdentifier: "personalInfoCell")
        
        var title = ""
        if user.uid == vkSingleton.shared.userID {
            title = "Подробная информация обо мне"
        } else {
            title = "Подробная информация о \(user.firstNameAbl) \(user.lastNameAbl)"
            let fc = user.firstNameAbl.prefix(1)
            if fc == "А" || fc == "И" || fc == "О" || fc == "Е" || fc == "У" || fc == "Я" || fc == "Ы" || fc == "Ё" || fc == "Э" || fc == "Ю"  {
                title = "Подробная информация об \(user.firstNameAbl) \(user.lastNameAbl)"
            }
        }
        self.title = title
        
        setHeader()
        
        if user.relativesList != "" {
            let url = "/method/users.get"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "user_ids": user.relativesList,
                "fields": "id,first_name,last_name,sex",
                "name_case": "nom",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                self.relatives = json["response"].compactMap { UserProfile(json: $0.1) }
                
                OperationQueue.main.addOperation {
                    self.prepareInfo()
                    self.tableView.reloadData()
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        } else {
            prepareInfo()
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return countBasicInfoSection
        case 1:
            return countContactInfoSection
        case 2:
            if user.relatives.count > 0 {
                return 1
            }
            return 0
        case 3:
            return countLifePositionSection
        case 4:
            return countPersonalInfoSection
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "relativeCell") as! RelativeCell
            
            return cell.getRowHeight(user: user)
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoCell") as! PersonalInfoCell
            
            cell.delegate = self
            cell.inform = lifePositionSection[indexPath.row]
            cell.cellWidth = self.width
            
            return cell.getRowHeight()
        }
        
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoCell") as! PersonalInfoCell
            
            cell.delegate = self
            cell.inform = personalInfoSection[indexPath.row]
            cell.cellWidth = self.width
            
            return cell.getRowHeight()
        }
        
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = vkSingleton.shared.backColor
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = vkSingleton.shared.backColor
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        
        if section == 2 {
            if user.relatives.count == 0 {
                return 0
            }
        }
        if section == 3 {
            if countLifePositionSection == 0 {
                return 0
            }
        }
        if section == 4 {
            if countPersonalInfoSection == 0 {
                return 0
            }
        }
        
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 4 {
            return 5
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicInfoCell", for: indexPath)
            
            if countBasicInfoSection > 0 {
                cell.imageView?.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                cell.imageView?.image = UIImage(named: basicInfoSection[indexPath.row].image)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\(basicInfoSection[indexPath.row].value)"
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactInfoCell", for: indexPath)
            
            if countContactInfoSection > 0 {
                cell.imageView?.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                cell.imageView?.image = UIImage(named: contactInfoSection[indexPath.row].image)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\(contactInfoSection[indexPath.row].value)"
                
                if contactInfoSection[indexPath.row].comment == "site" {
                    cell.textLabel?.prepareTextForPublish2(self, cell: nil)
                }
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "relativeCell", for: indexPath) as! RelativeCell
            
            cell.delegate = self
            cell.cellWidth = self.width
            cell.configureCell(relatives: user.relatives, users: relatives)
            
            cell.selectionStyle = .none
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoCell", for: indexPath) as! PersonalInfoCell
            
            cell.delegate = self
            cell.inform = lifePositionSection[indexPath.row]
            cell.cellWidth = self.width
            
            cell.configureCell()
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoCell", for: indexPath) as! PersonalInfoCell
            
            cell.delegate = self
            cell.inform = personalInfoSection[indexPath.row]
            cell.cellWidth = self.width
            
            cell.configureCell()
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    func setHeader() {
        let view = UIView()
        view.backgroundColor = vkSingleton.shared.backColor
        
        let titleView = UIView()
        titleView.backgroundColor = UIColor.white
        
        let width = self.width - 10
        
        let avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "nophoto")
        let getCacheImage = GetCacheImage(url: user.maxPhotoURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatarImage.image = getCacheImage.outputImage
                avatarImage.layer.cornerRadius = 20
                avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        avatarImage.frame = CGRect(x: 20, y: 10, width: 40, height: 40)
        titleView.addSubview(avatarImage)
        
        let nameLabel = UILabel()
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 16)
        nameLabel.frame = CGRect(x: 70, y: 20, width: width * 0.5 - 70, height: 20)
        titleView.addSubview(nameLabel)
        
        let lastLabel = UILabel()
        if user.deactivated == "" {
            if user.onlineStatus == 1 {
                lastLabel.text = " онлайн"
                lastLabel.textColor = UIColor.blue
                lastLabel.isEnabled = true
            } else {
                let date = NSDate(timeIntervalSince1970: Double(user.lastSeen))
                let strDate = dateFormatter.string(from: date as Date)
                
                if user.sex == 1 {
                    lastLabel.text = " заходила \(strDate)"
                    
                } else {
                    lastLabel.text = " заходил \(strDate)"
                }
                lastLabel.isEnabled = false
            }
        } else {
            if user.deactivated == "deleted" {
                lastLabel.text = " Страница удалена"
            } else {
                lastLabel.text = " Страница заблокирована"
            }
            lastLabel.isEnabled = false
        }
        
        if user.platform > 0 && user.platform != 7 {
            lastLabel.setPlatformStatus(text: "\(lastLabel.text!)", platform: user.platform, online: user.onlineStatus)
        }
        
        lastLabel.textAlignment = .right
        lastLabel.frame = CGRect(x: width * 0.5 + 10, y: 20, width: width * 0.5 - 30, height: 20)
        lastLabel.font = UIFont(name: "Verdana", size: 12)
        lastLabel.adjustsFontSizeToFitWidth = true
        lastLabel.minimumScaleFactor = 0.5
        titleView.addSubview(lastLabel)
        
        var topY: CGFloat = 60
        if user.status != "" {
            setSeparator(inView: titleView, topY: 60)
            
            let statusLabel = UILabel()
            statusLabel.text = user.status
            statusLabel.font = UIFont(name: "Verdana", size: 15)!
            statusLabel.textAlignment = .center
            let size = self.getTextSize(text: statusLabel.text!, font: statusLabel.font, maxWidth: width - 40)
            statusLabel.numberOfLines = 0
            statusLabel.frame = CGRect(x: 20, y: topY, width: width - 40, height: size.height + 30)
            statusLabel.prepareTextForPublish2(self, cell: nil)
            titleView.addSubview(statusLabel)
            
            topY += size.height + 30
        }
        
        titleView.layer.borderColor = UIColor.gray.cgColor
        titleView.layer.borderWidth = 0.8
        
        titleView.frame = CGRect(x: 5, y: 5, width: width, height: topY)
        view.addSubview(titleView)
        
        view.frame = CGRect(x: 0, y: 0, width: self.width, height: topY + 10)
        
        tableView.tableHeaderView = view
    }
    
    func setSeparator(inView view: UIView, topY: CGFloat) {
        let separator = UIView()
        separator.frame = CGRect(x: 10, y: topY, width: width - 40, height: 0.8)
        separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
        separator.layer.borderWidth = 0.1
        separator.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(separator)
    }
    
    func prepareInfo() {
        
        var personal: InfoInProfile
        
        countBasicInfoSection = 0
        countContactInfoSection = 0
        countPersonalInfoSection = 0
        countLifePositionSection = 0
        
        basicInfoSection.removeAll(keepingCapacity: false)
        contactInfoSection.removeAll(keepingCapacity: false)
        personalInfoSection.removeAll(keepingCapacity: false)
        lifePositionSection.removeAll(keepingCapacity: false)
        relativesSection.removeAll(keepingCapacity: false)
        
            
        // раздел "Основная информация"
        if user.relation != 0 {
            countBasicInfoSection += 1
            personal = InfoInProfile("relation",user.familyStatus,"relation")
            basicInfoSection.append(personal)
        }
        
        if user.birthDate != "" {
            countBasicInfoSection += 1
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
            dateFormatter.dateFormat = "dd.M.yyyy"
            var date = dateFormatter.date(from: user.birthDate)
            dateFormatter.dateFormat = "dd MMMM yyyy года"
            if date == nil {
                dateFormatter.dateFormat = "dd.M"
                date = dateFormatter.date(from: user.birthDate)
                dateFormatter.dateFormat = "dd MMMM"
            }
            personal = InfoInProfile("birthdate",dateFormatter.string(from: date!),"birthDate")
            
            basicInfoSection.append(personal)
        }
        
        if user.homeTown != "" {
            countBasicInfoSection += 1
            personal = InfoInProfile("city", user.homeTown, "city")
            basicInfoSection.append(personal)
            
        }
        
        if user.universityName != "" {
            countBasicInfoSection += 1
            var univerName = user.universityName
            if user.universityGraduation != 0 {
                univerName = "\(univerName) '\(user.universityGraduation)"
            }
            personal = InfoInProfile("university", univerName, "education")
            basicInfoSection.append(personal)
        }
        
        if user.facultyName != "" {
            countBasicInfoSection += 1
            personal = InfoInProfile("faculty", user.facultyName, "education")
            basicInfoSection.append(personal)
        }
        
        // раздел "Контакты"
        if user.mobilePhone != "" {
            countContactInfoSection += 1
            personal = InfoInProfile("phone",user.mobilePhone,"phone")
            contactInfoSection.append(personal)
        }
        
        if user.site != "" {
            countContactInfoSection += 1
            personal = InfoInProfile("site",user.site,"site")
            contactInfoSection.append(personal)
        }
        
        countContactInfoSection += 1
        personal = InfoInProfile("id","id\(user.uid)","id")
        contactInfoSection.append(personal)
        
        if user.domain != "" && user.domain != "id\(user.uid)"{
            countContactInfoSection += 1
            personal = InfoInProfile("vk",user.domain,"vk")
            contactInfoSection.append(personal)
        }
        
        if user.skype != "" {
            countContactInfoSection += 1
            personal = InfoInProfile("skype",user.skype,"skype")
            contactInfoSection.append(personal)
        }
        
        if user.facebook != "" {
            countContactInfoSection += 1
            personal = InfoInProfile("facebook",user.facebook,"facebook")
            contactInfoSection.append(personal)
        }
        
        if user.twitter != "" {
            countContactInfoSection += 1
            personal = InfoInProfile("twitter",user.twitter,"twitter")
            contactInfoSection.append(personal)
        }
        
        if user.instagram != "" {
            countContactInfoSection += 1
            personal = InfoInProfile("instagram",user.instagram,"instagram")
            contactInfoSection.append(personal)
        }
        
        // раздел "Личная информация"
        if user.about != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("О себе",user.about,"about")
            personalInfoSection.append(personal)
        }
        
        if user.activities != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Деятельность",user.activities,"activities")
            personalInfoSection.append(personal)
        }
        
        if user.interests != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Интересы",user.interests,"interests")
            personalInfoSection.append(personal)
        }
        
        if user.books != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Любимые книги",user.books,"books")
            personalInfoSection.append(personal)
        }
        
        if user.games != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Любимые игры",user.games,"games")
            personalInfoSection.append(personal)
        }
        
        if user.movies != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Любимые фильмы",user.movies,"movies")
            personalInfoSection.append(personal)
        }
        
        if user.music != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Любимая музыка",user.music,"music")
            personalInfoSection.append(personal)
        }
        
        if user.tv != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Любимые телешоу",user.tv,"tv")
            personalInfoSection.append(personal)
        }
        
        if user.quotes != "" {
            countPersonalInfoSection += 1
            personal = InfoInProfile("Любимые цитаты",user.quotes,"quotes")
            personalInfoSection.append(personal)
        }
        
        // раздел "Жизненная позиция"
        if user.persPolitical != 0 {
            countLifePositionSection += 1
            personal = InfoInProfile("Политические предпочтения",user.politicalConviction,"political")
            lifePositionSection.append(personal)
        }
        
        if user.persReligion != "" {
            countLifePositionSection += 1
            personal = InfoInProfile("Мировоззрение",user.persReligion,"religion")
            lifePositionSection.append(personal)
        }
        
        if user.persInspired != "" {
            countLifePositionSection += 1
            personal = InfoInProfile("Источники вдохновения",user.persInspired,"inspired")
            lifePositionSection.append(personal)
        }
        
        if user.persPeopleMain != 0 {
            countLifePositionSection += 1
            personal = InfoInProfile("Главное в людях",user.mainInPeople,"people_main")
            lifePositionSection.append(personal)
        }
        
        if user.persLifeMain != 0 {
            countLifePositionSection += 1
            personal = InfoInProfile("Главное в жизни",user.mainInLife,"life_main")
            lifePositionSection.append(personal)
        }
        
        if user.persSmoking != 0 {
            countLifePositionSection += 1
            personal = InfoInProfile("Отношение к курению",user.smokingRelation,"smoking")
            lifePositionSection.append(personal)
        }
        
        if user.persAlcohol != 0 {
            countLifePositionSection += 1
            personal = InfoInProfile("Отношение к алкоголю",user.alcoholRelation,"alcohol")
            lifePositionSection.append(personal)
        }
    }
}

struct InfoInProfile {
    var image: String
    var value: String
    var comment: String
    
    init(_ image: String, _ value: String, _ comment: String) {
        self.image = image
        self.value = value
        self.comment = comment
    }
}
