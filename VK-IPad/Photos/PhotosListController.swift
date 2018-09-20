//
//  PhotosListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PhotosListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: UIViewController!
    
    var ownerID = ""
    var albumID = ""
    
    var offset = 0
    var count = 200
    var photosCount = 0
    var isRefresh = false
    var type = ""
    var source = ""
    
    var photos: [Photo] = []
    var albums: [PhotoAlbum] = []
    
    var selectIndex = 0
    
    var selectButton: UIBarButtonItem!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var tableView = UITableView()
    
    var heightRow: CGFloat = 0
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.configureTableView()
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator2(controller: self)
        }
        
        getPhotos()
        StoreReviewHelper.checkAndAskForReview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
        tableView.register(PhotoAlbumsListCell.self, forCellReuseIdentifier: "albumCell")
        
        if type == "album" {
            tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
            tableView.register(PhotoAlbumsListCell.self, forCellReuseIdentifier: "albumCell")
            
            tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        } else {
            tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
            
            tableView.frame = CGRect(x: 0, y: segmentedControl.frame.maxY + 10, width: self.view.bounds.width, height: self.view.bounds.height - segmentedControl.frame.maxY - 10)
        }
        
        self.view.addSubview(tableView)
    }
    
    func getPhotos() {
        isRefresh = true
        
        let opq = OperationQueue()
        
        if type != "album" {
            let url = "/method/photos.getAll"
            let parameters = [
                "owner_id": ownerID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "offset": "\(offset)",
                "count": "\(count)",
                "photo_sizes": "0",
                "skip_hidden": "0",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parsePhotos = ParsePhotosList()
            parsePhotos.addDependency(getServerDataOperation)
            opq.addOperation(parsePhotos)
            
            let url2 = "/method/photos.getAlbums"
            let parameters2 = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": ownerID,
                "need_system": "1",
                "need_covers": "1",
                "photo_sizes": "0",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
            opq.addOperation(getServerDataOperation2)
            
            let parsePhotoAlbums = ParsePhotoAlbums()
            parsePhotoAlbums.addDependency(getServerDataOperation2)
            opq.addOperation(parsePhotoAlbums)
            
            let reloadTableController = ReloadPhotosListController(controller: self)
            reloadTableController.addDependency(parsePhotos)
            reloadTableController.addDependency(parsePhotoAlbums)
            OperationQueue.main.addOperation(reloadTableController)
        } else {
            let url = "/method/photos.get"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": ownerID,
                "album_id": albumID,
                "rev": "1",
                "extended": "1",
                "offset": "\(offset)",
                "count": "\(count)",
                "photo_sizes": "0",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parsePhotos = ParsePhotosList()
            parsePhotos.addDependency(getServerDataOperation)
            opq.addOperation(parsePhotos)
            
            let reloadTableController = ReloadPhotosListController(controller: self)
            reloadTableController.addDependency(parsePhotos)
            OperationQueue.main.addOperation(reloadTableController)
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
        case 0:
            selectIndex = 0
            tableView.separatorStyle = .none
            heightRow = (self.view.bounds.width * 0.333) * CGFloat(240) /
                CGFloat(320)
            
            if source == "" {
                if let id = Int(ownerID) {
                    if id > 0 {
                        self.title = self.title?.replacingFirstOccurrence(of: "Альбомы", with: "Фотографии")
                        self.title = self.title?.replacingFirstOccurrence(of: "альбомы", with: "фотографии")
                    } else {
                        self.title = self.title?.replacingFirstOccurrence(of: "Альбомы", with: "Фотографии")
                    }
                }
            }
        case 1:
            selectIndex = 1
            tableView.separatorStyle = .none
            heightRow = (self.view.bounds.width * 0.5) * CGFloat(240) / CGFloat(320) + 50
            
            if source == "" {
                if let id = Int(ownerID) {
                    if id > 0 {
                        self.title = self.title?.replacingFirstOccurrence(of: "Фотографии", with: "Альбомы")
                        self.title = self.title?.replacingFirstOccurrence(of: "фотографии", with: "альбомы")
                    } else {
                        self.title = self.title?.replacingFirstOccurrence(of: "Фотографии", with: "Альбомы")
                    }
                }
            }
        default:
            break
        }
        
        self.tableView.estimatedRowHeight = heightRow
        self.tableView.rowHeight = heightRow
        self.tableView.reloadData()
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectIndex == 1 {
            return albums.count / 2 + albums.count % 2
        }
        return photos.count / 3 + photos.count % 3
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotosListCell
            
            cell.delegate = self
            cell.photos = photos
            
            cell.indexPath = indexPath
            cell.tableView = self.tableView
            
            cell.cellWidth = self.view.bounds.width
            cell.source = source
            
            cell.configureCell()
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! PhotoAlbumsListCell
            
            cell.delegate = self
            cell.albums = albums
            
            cell.indexPath = indexPath
            cell.cellWidth = self.view.bounds.width
            
            cell.configureCell()
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    @objc func tapSelectButton(sender: UIBarButtonItem) {
        
        if source == "add_photo" {
            let photos = self.photos.filter({ $0.isSelected })
            
            if let controller = delegate as? RecordController {
                for photo in photos {
                    controller.attachPanel.attachArray.append(photo)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
            } else if let controller = delegate as? VideoController {
                for photo in photos {
                    controller.attachPanel.attachArray.append(photo)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
            } else if let controller = delegate as? TopicController {
                for photo in photos {
                    controller.attachPanel.attachArray.append(photo)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
            } else if let controller = delegate as? DialogController {
                for photo in photos {
                    controller.attachPanel.attachArray.append(photo)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
                controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            } else if let controller = delegate as? NewRecordController {
                for photo in photos {
                    controller.attachPanel.attachArray.append(photo)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
                controller.tableView.reloadData()
            } else if let controller = delegate as? AddNewTopicController {
                for photo in photos {
                    controller.attachPanel.attachArray.append(photo)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
                controller.tableView.reloadData()
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if selectIndex == 0 {
            if indexPath.row == tableView.numberOfRows(inSection: 0)-1 && offset < photosCount {
                isRefresh = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if selectIndex == 0 && isRefresh == false {
            getPhotos()
        }
    }
}
