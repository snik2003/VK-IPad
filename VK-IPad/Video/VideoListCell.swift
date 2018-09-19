//
//  VideoListCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 22.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import BEMCheckBox

class VideoListCell: UITableViewCell {
    
    var videoImage: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var viewsLabel: UILabel!
    var durationLabel: UILabel!
    var markCheck: BEMCheckBox!
    var fadeImage: UIImageView!
    
    weak var delegate: UIViewController!
    
    var video: Video!
    var source: String = ""
    
    var indexPath: IndexPath!
    var cell: UITableViewCell!
    var tableView: UITableView!
    
    
    var cellWidth: CGFloat = 0
    
    let leftInsets: CGFloat = 10
    let topInsets: CGFloat = 0
    
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        let videoWidth: CGFloat = cellWidth * 0.5
        let videoHeight: CGFloat = 240 * videoWidth / 320
        
        if source != "" {
            videoImage = UIImageView()
            
            let getCacheImage = GetCacheImage(url: video.photo320, lifeTime: .userPhotoImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: videoImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                self.videoImage.contentMode = .scaleAspectFit
                self.videoImage.clipsToBounds = true
            }
            
            videoImage.frame = CGRect(x: leftInsets, y: topInsets, width: videoWidth, height: videoHeight)
            
            self.addSubview(videoImage)
            
            
            let vidImage = UIImageView()
            vidImage.tag = 250
            vidImage.image = UIImage(named: "video")
            vidImage.frame = CGRect(x: videoWidth / 2 - 20, y: videoHeight / 2 - 20, width: 40, height: 40)
            videoImage.addSubview(vidImage)
        } else {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.black
            
            view.frame = CGRect(x: leftInsets, y: topInsets, width: videoWidth, height: videoHeight)
            self.addSubview(view)
            
            let loadingView = UIView()
            loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            loadingView.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
            loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 8
            view.addSubview(loadingView)
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0, y: 0, width: loadingView.frame.maxX, height: loadingView.frame.maxY);
            activityIndicator.activityIndicatorViewStyle = .white
            activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
            loadingView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            let webView = WKWebView()
            webView.tag = 250
            webView.isOpaque = false
            webView.frame = CGRect(x: leftInsets, y: topInsets, width: videoWidth, height: videoHeight)
            
            if let controller = delegate as? WKNavigationDelegate {
                webView.navigationDelegate = controller
            }
            
            if video.player == "" {
                let url = "/method/video.get"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": "\(video.ownerID)",
                    "videos": "\(video.ownerID)_\(video.id)_\(video.accessKey)",
                    "v": vkSingleton.shared.version
                ]
                let getServerData = GetServerDataOperation(url: url, parameters: parameters)
                getServerData.completionBlock = {
                    guard let data = getServerData.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let videos = json["response"]["items"].compactMap({ Video(json: $0.1) })
                    if videos.count > 0 {
                        if let url = URL(string: videos[0].player) {
                            let request = URLRequest(url: url)
                            OperationQueue.main.addOperation {
                                webView.load(request)
                                self.addSubview(webView)
                                if let controller = self.delegate as? VideoListController {
                                    controller.videos[self.indexPath.section].player = videos[0].player
                                } else if let controller = self.delegate as? FavePostsController {
                                    controller.videos[self.indexPath.section].player = videos[0].player
                                }
                                self.video.player = videos[0].player
                            }
                        }
                    }
                }
                OperationQueue().addOperation(getServerData)
            } else {
                if let url = URL(string: video.player) {
                    let request = URLRequest(url: url)
                    webView.load(request)
                    self.addSubview(webView)
                }
            }
        }
        
        let maxWidth = cellWidth - 3 * leftInsets - videoWidth
        let leftX = 2 * leftInsets + videoWidth
        titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.text = video.title
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.contentMode = .center
        titleLabel.numberOfLines = 0
        titleLabel.clipsToBounds = true
        titleLabel.prepareTextForPublish2(self.delegate, cell: self)
        
        let titleSize = delegate.getTextSize(text: titleLabel.text!, font: titleLabel.font, maxWidth: maxWidth)
        titleLabel.frame = CGRect(x: leftX, y: topInsets + 10, width: maxWidth, height: titleSize.height + 10)
        self.addSubview(titleLabel)
        
        var descSize = CGSize(width: 0, height: 0)
        
        descriptionLabel = UILabel()
        descriptionLabel.tag = 250
        if video.description != "" {
            descriptionLabel.text = video.description
            descriptionLabel.isEnabled = true
        } else {
            descriptionLabel.text = "Описание к видео отсутствует"
            descriptionLabel.isEnabled = false
        }
        descriptionLabel.font = UIFont(name: "Verdana", size: 12)!
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.textAlignment = .center
        descriptionLabel.contentMode = .center
        descriptionLabel.prepareTextForPublish2(self.delegate, cell: self)
        
        descriptionLabel.clipsToBounds = true
        
        descSize = delegate.getTextSize(text: descriptionLabel.text!, font: descriptionLabel.font, maxWidth: maxWidth)
        descSize.height = topInsets + videoHeight - 40 - titleSize.height - 30
        descriptionLabel.frame = CGRect(x: leftX, y: titleLabel.frame.maxY, width: maxWidth, height: descSize.height)
        self.addSubview(descriptionLabel)
        
        viewsLabel = UILabel()
        viewsLabel.tag = 250
        viewsLabel.text = "Количество просмотров: \(video.views.getCounterToString())"
        viewsLabel.font = UIFont(name: "Verdana", size: 11)!
        viewsLabel.textColor = UIColor.black //viewsLabel.tintColor
        //viewsLabel.isEnabled = false
        viewsLabel.textAlignment = .center
        viewsLabel.contentMode = .center
        viewsLabel.numberOfLines = 1
        viewsLabel.clipsToBounds = true
        
        viewsLabel.frame = CGRect(x: leftX, y: topInsets + videoHeight - 36, width: maxWidth, height: 18)
        self.addSubview(viewsLabel)
        
        durationLabel = UILabel()
        durationLabel.tag = 250
        durationLabel.text = "Длительность видео: \(video.duration.getVideoDurationToString())"
        durationLabel.font = UIFont(name: "Verdana", size: 11)!
        durationLabel.textColor = UIColor.black //durationLabel.tintColor
        //durationLabel.isEnabled = false
        durationLabel.textAlignment = .center
        durationLabel.contentMode = .center
        durationLabel.numberOfLines = 1
        durationLabel.clipsToBounds = true
        
        durationLabel.frame = CGRect(x: leftX, y: topInsets + videoHeight - 18, width: maxWidth, height: 18)
        self.addSubview(durationLabel)
        
        if source != "" {
            markCheck = BEMCheckBox()
            markCheck.tag = 250
            markCheck.onTintColor = vkSingleton.shared.mainColor
            markCheck.onCheckColor = vkSingleton.shared.mainColor
            markCheck.lineWidth = 3
            
            markCheck.on = video.isSelected
            
            markCheck.frame = CGRect(x: leftInsets + 15, y: topInsets + 15, width: 30, height: 30)
            
            fadeImage = UIImageView()
            fadeImage.tag = 250
            if video.isSelected {
                fadeImage.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.75)
            } else {
                fadeImage.backgroundColor = UIColor.clear
            }
            fadeImage.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cell.bounds.height)
            self.addSubview(fadeImage)
            self.addSubview(markCheck)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if source != "" {
            markCheck.on = selected
            
            if selected {
                fadeImage.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.75)
            } else {
                fadeImage.backgroundColor = UIColor.clear
            }
            
            if let controller = self.delegate as? VideoListController {
                let videos = controller.videos.filter({ $0.isSelected == true })
                
                if videos.count > 0 {
                    controller.selectButton.isEnabled = true
                    controller.selectButton.title = "Вложить (\(videos.count))"
                } else {
                    controller.selectButton.isEnabled = false
                    controller.selectButton.title = "Вложить"
                }
            }
        }
    }
}
