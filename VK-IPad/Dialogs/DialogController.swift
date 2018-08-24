//
//  DialogController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 24.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import DCCommentView
import SwiftyJSON

enum DialogMode {
    case dialog
}

class DialogController: UIViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate {
    
    var userID = ""
    
    var delegate: UIViewController!
    
    var heights: [IndexPath: CGFloat] = [:]
    var width: CGFloat = 0
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    var attachPanel = AttachPanel()
    
    var dialogs: [Dialog] = []
    
    var startMessageID = -1
    var offset = 0
    var count = 50
    var totalCount = 0
    var mode = DialogMode.dialog
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.attachPanel.delegate = self
        self.configureTableView()
        
        self.tableView.separatorStyle = .none
        
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        setDialogTitle()
        getDialog()
        
        if userID == vkSingleton.shared.supportGroupID {
            let feedbackText = "Здесь Вы можете оставить отзыв о приложении «ВКлючайся!»:\n\nзадать любой вопрос по функционалу приложения,\nсообщить об обнаруженной ошибке или внести\nпредложение по усовершенствованию приложения.\n\nМы будем рады любому отзыву и обязательно ответим Вам.\n\nЖдём ваших отзывов! 😊"
            
            self.showSuccessMessage(title: "Друзья!", msg: feedbackText)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height)
        
        
        commentView = DCCommentView(scrollView: self.tableView, frame: self.tableView.bounds)
        commentView.delegate = self
        commentView.tintColor = vkSingleton.shared.mainColor
            
        commentView.sendImage = UIImage(named: "send2")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
            
        commentView.accessoryImage = UIImage(named: "attachment2")?.tint(tintColor: vkSingleton.shared.mainColor)
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
            
        setCommentFromGroupID(id: 0, controller: self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(commentView)
    }
    
    func didSendComment(_ text: String!) {
        
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
        let selectView = SelectAttachPanel()
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.button = self.commentView.accessoryButton
        
        selectView.ownerID = "\(userID)"
        
        selectView.show()
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.stickerButton.buttonTouched()
        
        let stickerView = StickerView()
        stickerView.width = 320
        stickerView.height = stickerView.width + 70
        
        stickerView.delegate = self
        stickerView.button = self.commentView.stickerButton
        stickerView.numProd = 1
        
        stickerView.show()
    }
    
    func getDialog() {
        ViewControllerUtils().hideActivityIndicator()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return attachPanel.frame.height + 5
        }
        
        if indexPath.section == 1 {
            if dialogs.count < totalCount {
                return 50
            }
            return 10
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func setDialogTitle() {
        OperationQueue.main.addOperation {
            let titleView = DialogTitleView()
            titleView.delegate = self
            titleView.configure()
        }
    }
}
