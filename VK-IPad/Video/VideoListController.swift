//
//  VideoListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 22.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit

class VideoListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,WKNavigationDelegate {
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    weak var delegate: UIViewController!
    
    let heightRow: CGFloat = 0
    
    var videos: [Video] = []
    var searchVideos: [Video] = []
    var requestVideos: [Video] = []
    
    var ownerID = ""
    var offset = 0
    var count = 100
    var isRefresh = false
    var isSearch = false
    var type = ""
    var source = ""
    
    var selectButton: UIBarButtonItem!
    
    var heights: [IndexPath: CGFloat] = [:]
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.createSearchBar()
            self.createTableView()
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBarStyle.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            
            if self.ownerID == vkSingleton.shared.userID && self.type == "" && self.source == "" {
                let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                self.navigationItem.rightBarButtonItem = barButton
            }
            
            if self.source != "" {
                self.selectButton = UIBarButtonItem(title: "Вложить", style: .done, target: self, action: #selector(self.tapSelectButton(sender:)))
                self.navigationItem.rightBarButtonItem = self.selectButton
                self.selectButton.isEnabled = false
                
                self.tableView.allowsMultipleSelection = true
            }
            
            self.tableView.separatorStyle = .none
            if self.type != "search" {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
        }
        
        if type != "search" {
            refresh()
        }
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 64, width: self.view.bounds.width, height: 56))
        
        self.view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - searchBar.frame.maxY)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
        
        tableView.register(VideoListCell.self, forCellReuseIdentifier: "videoCell")
        
        self.view.addSubview(tableView)
    }
    
    func refresh() {
        isRefresh = true
        
        let url = "/method/video.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        queue.addOperation(getServerDataOperation)
        
        let parseVideos = ParseVideos()
        parseVideos.addDependency(getServerDataOperation)
        queue.addOperation(parseVideos)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        let reloadTableController = ReloadVideoListController(controller: self)
        reloadTableController.addDependency(parseVideos)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func refreshSearch() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        isRefresh = true
        let text = searchBar.text!
        let opq = OperationQueue()
        
        let url = "/method/video.search"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "q": text,
            "sort": "0",
            "filters": "youtube",
            "offset": "0",
            "count": "\(count)",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseVideos = ParseVideos()
        parseVideos.addDependency(getServerDataOperation)
        queue.addOperation(parseVideos)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        let reloadTableController = ReloadVideoListController(controller: self)
        reloadTableController.addDependency(parseVideos)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width * 0.5 * CGFloat(240) / CGFloat(320)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        }
        return 25
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 15
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor.white
        
        let separator = UIView()
        if section == 0 {
            separator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5)
        } else {
            separator.frame = CGRect(x: 0, y: 10, width: tableView.bounds.width, height: 5)
        }
        separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
        viewHeader.addSubview(separator)
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor.white
        
        let separator = UIView()
        separator.frame = CGRect(x: 0, y: 10, width: tableView.bounds.width, height: 5)
        separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
        viewFooter.addSubview(separator)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoListCell
        
        cell.delegate = self
        
        cell.video = videos[indexPath.section]
        cell.indexPath = indexPath
        cell.cell = cell
        cell.tableView = tableView
        cell.cellWidth = tableView.bounds.width
        cell.source = source
        
        cell.configureCell()
        
        if cell.video.isSelected {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfRows(inSection: 0) - 1 && indexPath.section == offset - 1 {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false && type != "search" {
            refresh()
        }
    }
    
    @objc func tapSelectButton(sender: UIBarButtonItem) {
        
        if source == "add_video" {
            let videos = self.videos.filter({ $0.isSelected })
            
            if let controller = delegate as? RecordController {
                for video in videos {
                    controller.attachPanel.attachArray.append(video)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
            } else if let controller = delegate as? VideoController {
                for video in videos {
                    controller.attachPanel.attachArray.append(video)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
            } else if let controller = delegate as? TopicController {
                for video in videos {
                    controller.attachPanel.attachArray.append(video)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
            } else if let controller = delegate as? DialogController {
                for video in videos {
                    controller.attachPanel.attachArray.append(video)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
                controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            } else if let controller = delegate as? NewRecordController {
                for video in videos {
                    controller.attachPanel.attachArray.append(video)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
                controller.tableView.reloadData()
            } else if let controller = delegate as? AddNewTopicController {
                for video in videos {
                    controller.attachPanel.attachArray.append(video)
                }
                controller.attachPanel.removeFromSuperview()
                controller.attachPanel.reconfigure()
                controller.tableView.reloadData()
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        if source != "" {
            videos[indexPath.section].isSelected = true
        } else {
            let video = videos[indexPath.section]
            
            self.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if source != "" {
            videos[indexPath.section].isSelected = false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        isSearch = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if type != "search" {
            searchVideos = requestVideos.filter({ "\($0.title) \($0.description)".containsIgnoringCase(find: searchText) })
            
            if searchVideos.count == 0 {
                videos = requestVideos
                isSearch = false
            } else {
                videos = searchVideos
                isSearch = true
            }
            
            self.tableView.reloadData()
        } else {
            refreshSearch()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        self.openVideoListController(ownerID: ownerID, title: "Глобальный поиск видео", type: "search")
    }
}
