//
//  PhotoViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import ImageScrollView

class PhotoViewController: UITableViewController {

    var delegate: UIViewController!
    
    var photos: [Photo] = []
    var photo: [Photo] = []
    var numPhoto: Int = 0
    
    var likes: [Likes] = []
    var reposts: [Likes] = []
    
    var pinch = UIPinchGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let photo = photos[numPhoto]
        var code = "var a = API.photos.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"photos\":\"\(photo.ownerID)_\(photo.id)_\(photo.accessKey)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(photo.ownerID)\",\"item_id\":\"\(photo.id)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var c = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(photo.ownerID)\",\"item_id\":\"\(photo.id)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) return [a,b,c];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let photos = json["response"][0].compactMap { Photo(json: $0.1) }
            let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
            let reposts = json["response"][2]["items"].compactMap { Likes(json: $0.1) }
            
            OperationQueue.main.addOperation {
                self.photo = photos
                self.likes = likes
                self.reposts = reposts
                
                if self.photo.count > 0 {
                    let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                    self.navigationItem.rightBarButtonItem = barButton
                }
                
                self.title = "Фотография"
                if self.photos.count > 1 {
                    self.title = "Фотография \(self.numPhoto + 1)/\(self.photos.count)"
                }
                self.tableView.reloadData()
                
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                
                leftSwipe.direction = .left
                rightSwipe.direction = .right
                
                self.view.addGestureRecognizer(leftSwipe)
                self.view.addGestureRecognizer(rightSwipe)
                
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue.main.addOperation(getServerDataOperation)
        StoreReviewHelper.checkAndAskForReview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if photo.count == 0 {
            return 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if photo.count == 0 {
                return self.tableView.bounds.height - 64
            }
            return self.tableView.bounds.height - 40 - 64
        case 1:
            return 40
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 2
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoViewCell
            
            ViewControllerUtils().showActivityIndicator2(controller: self)
            cell.backgroundColor = UIColor(displayP3Red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
            let photo = photos[numPhoto]
            
            var url = photo.photo2560
            if url == "" {
                url = photo.photo1280
                if url == "" {
                    url = photo.photo807
                    if url == "" {
                        url = photo.photo604
                    }
                }
            }
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    if let myImage = getCacheImage.outputImage {
                        cell.imageScrollView.imageContentMode = .aspectFit
                        cell.imageScrollView.initialOffset = .center
                        cell.imageScrollView.display(image: myImage)
                    }
                    
                    
                    /*cell.photoImage.contentMode = .scaleAspectFit
                    
                    cell.photoImage.isUserInteractionEnabled = true
                    cell.photoImage.addGestureRecognizer(self.pinch)
                    self.pinch.add {
                        if self.pinch.scale < 1.0 {
                            self.pinch.scale = 1.0
                        } else if self.pinch.scale > 12.0 {
                            self.pinch.scale = 12.0
                        }
                        cell.photoImage.transform = CGAffineTransform(scaleX: self.pinch.scale, y: self.pinch.scale)
                    }*/
                    
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "likesCell", for: indexPath) as! PhotoViewCell
            
            cell.backgroundColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            
            if photo.count > 0 {
                cell.delegate = self
                cell.photo = photo[0]
                
                cell.cellWidth = self.tableView.bounds.width
                cell.configureLikesCell()
                
                cell.commentsButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.commentsButton.add(for: .touchUpInside) {
                    cell.commentsButton.smallButtonTouched()
                    self.openWallRecord(ownerID: cell.photo.ownerID, postID: cell.photo.id, accessKey: cell.photo.accessKey, type: "photo")
                }

                cell.usersButton.isEnabled = (self.likes.count > 0)
                cell.usersButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.usersButton.add(for: .touchUpInside) {
                    cell.usersButton.smallButtonTouched()
                    self.openLikesUsersController(likes: self.likes, reposts: self.reposts)
                }
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    @objc func handleSwipes(sender: UISwipeGestureRecognizer) {
        
        var start = false
        if (sender.direction == .right) {
            if numPhoto > 0 {
                numPhoto -= 1
                start = true
            }
        }
        
        if (sender.direction == .left) {
            if numPhoto < photos.count-1 {
                numPhoto += 1
                start = true
                
            }
        }
        
        if start {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PhotoViewCell,
                let noPhoto = UIImage(named: "nophoto") {
                cell.imageScrollView.display(image: noPhoto)
            }
            
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? PhotoViewCell {
                cell.removeAllSubviews()
            }
            
            let photo = photos[numPhoto]
            var code = "var a = API.photos.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"photos\":\"\(photo.ownerID)_\(photo.id)_\(photo.accessKey)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(photo.ownerID)\",\"item_id\":\"\(photo.id)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(photo.ownerID)\",\"item_id\":\"\(photo.id)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) return [a,b,c];"
            
            let url = "/method/execute"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                let photos = json["response"][0].compactMap { Photo(json: $0.1) }
                let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
                let reposts = json["response"][2]["items"].compactMap { Likes(json: $0.1) }
                
                OperationQueue.main.addOperation {
                    self.pinch.scale = 1.0
                    
                    self.photo = photos
                    self.likes = likes
                    self.reposts = reposts
                    
                    if self.photo.count > 0 {
                        let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                        self.navigationItem.rightBarButtonItem = barButton
                    }
                    
                    self.title = "Фотография"
                    if self.photos.count > 1 {
                        self.title = "Фотография \(self.numPhoto + 1)/\(self.photos.count)"
                    }
                    self.tableView.reloadData()
                    ViewControllerUtils().hideActivityIndicator()
                    
                    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                    
                    leftSwipe.direction = .left
                    rightSwipe.direction = .right
                    
                    self.view.addGestureRecognizer(leftSwipe)
                    self.view.addGestureRecognizer(rightSwipe)
                }
            }
            OperationQueue.main.addOperation(getServerDataOperation)
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        let photo = self.photo[0]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
            
            let link = "https://vk.com/photo\(photo.ownerID)_\(photo.id)"
                
            UIPasteboard.general.string = link
            if let string = UIPasteboard.general.string {
                self.showInfoMessage(title: "Ссылка на фотографию:" , msg: "\(string)")
            }
            
        }
        alertController.addAction(action1)
        
        
        let action2 = UIAlertAction(title: "Добавить в «Избранное»", style: .default) { action in
            
            self.addLinkToFave(object: photo)
        }
        alertController.addAction(action2)
        
        
        
        let action3 = UIAlertAction(title: "Сохранить в личном профиле", style: .default) { action in
            
            photo.copyToSaveAlbum(delegate: self)
        }
        alertController.addAction(action3)
        
        
        let action4 = UIAlertAction(title: "Сохранить в памяти устройства", style: .default) { action in
            
            photo.saveToDevice(delegate: self)
        }
        alertController.addAction(action4)
        
        
        let action5 = UIAlertAction(title: "Установить фото на аватар", style: .default) { action in
            
            
        }
        alertController.addAction(action5)
        
        
        if "\(photo.ownerID)" == vkSingleton.shared.userID {
            let action6 = UIAlertAction(title: "Удалить фотографию", style: .destructive) { action in
                
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleTop: 32.0,
                    kWindowWidth: 400,
                    kTitleFont: UIFont(name: "Verdana-Bold", size: 14)!,
                    kTextFont: UIFont(name: "Verdana", size: 15)!,
                    kButtonFont: UIFont(name: "Verdana", size: 16)!,
                    showCloseButton: false,
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                
                alertView.addButton("Да, хочу удалить") {
                    
                    photo.deleteFromSite(delegate: self)
                }
                
                alertView.addButton("Нет, я передумал") {}
                
                alertView.showWarning("Подтверждение!", subTitle: "Внимание! Данное действие необратимо.\nВы действительно хотите удалить эту фотографию с сайта ВКонтакте?")
            }
            alertController.addAction(action6)
        }
        
        
        let action7 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
            photo.reportMenu(delegate: self)
        }
        alertController.addAction(action7)
        
        
        if let popoverController = alertController.popoverPresentationController, let barButton = self.navigationItem.rightBarButtonItem {
            popoverController.barButtonItem = barButton
            popoverController.permittedArrowDirections = [.up]
        }
        
        self.present(alertController, animated: true)
    }
}
