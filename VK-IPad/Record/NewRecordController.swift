//
//  NewRecordController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

enum Mode {
    case new
    case edit
}

class NewRecordController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mode = Mode.new
    
    var ownerID = ""
    var width: CGFloat = 0
    
    var delegate: UIViewController!
    var attachPanel = AttachPanel()
    
    var record: Record!
    
    var textView = UITextView()
    
    var onlyFriends = false
    var addSigner = false
    var closeComments = false
    var postponed = false
    var postponedDate = 0
    var suggested = false
    
    @IBOutlet weak var attachButton: UIBarButtonItem!
    @IBOutlet weak var previewButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectView = SelectAttachPanel()
    
    var setDate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SwitchOptionCell.self, forCellReuseIdentifier: "switchCell")
        tableView.separatorStyle = .none
        
        let barButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapBarButton(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        
        configureAttachPanel()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height - 44, 0)
        
        let frame = tableView.frame
        tableView.contentSize = CGSize(width: frame.width, height: frame.height - kbSize.height - 44)
        
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
        tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: false)
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        tableView.contentInset = UIEdgeInsets.zero
        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
        
        if let popover = selectView.popover {
            popover.dismiss()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return attachPanel.frame.height + 5
        case 1,3:
            if suggested {
                return 0
            }
            return 40
        case 2:
            return 0
        case 4:
            return 310
        case 5:
            return 20
        case 6:
            if postponed && !setDate {
                return 20
            }
            return 0
        case 7:
            if postponed && setDate {
                return 250
            }
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchOptionCell
            
            cell.removeAllSubviews()
            
            if !suggested {
                cell.delegate = self
                cell.header = "Отложить публикацию записи"
                cell.desc = ""
                cell.cellWidth = self.width
                cell.optSwitch.isOn = postponed
                cell.optSwitch.addTarget(self, action: #selector(postponedSwitchValueChanged(sender:)), for: .valueChanged)
                cell.configureCell()
                
                if mode == .edit, let record = record {
                    if record.postType != "postpone" {
                        cell.headerLabel.isEnabled = false
                        cell.optSwitch.isEnabled = false
                    }
                    
                    if record.postType == "suggest" &&
                        vkSingleton.shared.adminGroups.filter({ $0.gid == abs(record.ownerID) }).count > 0 {
                        cell.headerLabel.isEnabled = true
                        cell.optSwitch.isEnabled = true
                    }
                }
            }
            
            cell.selectionStyle = .none
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchOptionCell
            
            cell.removeAllSubviews()
            
            /*if !suggested {
                cell.delegate = self
                cell.header = "Запретить комментарии записи"
                cell.desc = ""
                cell.cellWidth = self.width
                cell.optSwitch.isOn = closeComments
                cell.optSwitch.add(for: .valueChanged) {
                    self.closeComments = cell.optSwitch.isOn
                }
                cell.configureCell()
                
                if mode == .edit, let record = record {
                    if record.postType != "postpone" {
                        cell.headerLabel.isEnabled = false
                        cell.optSwitch.isEnabled = false
                    }
                }
            }*/
            
            cell.selectionStyle = .none
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchOptionCell
            
            cell.removeAllSubviews()
            
            if !suggested {
                if let id = Int(self.ownerID) {
                    cell.delegate = self
                    if id > 0 {
                        cell.header = "Публикация только для друзей"
                        cell.optSwitch.isOn = onlyFriends
                        cell.optSwitch.add(for: .valueChanged) {
                            self.onlyFriends = cell.optSwitch.isOn
                        }
                    } else {
                        cell.header = "Добавить к записи мою подпись"
                        cell.optSwitch.isOn = addSigner
                        cell.optSwitch.add(for: .valueChanged) {
                            self.addSigner = cell.optSwitch.isOn
                        }
                    }
                    cell.desc = ""
                    cell.cellWidth = self.width
                    
                    cell.configureCell()
                    
                    if mode == .edit, let record = record {
                        if record.postType != "postpone" && record.postType != "suggest" {
                            cell.headerLabel.isEnabled = false
                            cell.optSwitch.isEnabled = false
                        }
                    }
                }
            }
            
            cell.selectionStyle = .none
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.removeAllSubviews()
            
            textView.tag = 250
            textView.layer.cornerRadius = 6
            textView.layer.borderWidth = 0.8
            textView.layer.borderColor = UIColor.darkGray.cgColor
            textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            
            textView.font = UIFont(name: "Verdana", size: 15)
            textView.frame = CGRect(x: 10, y: 5, width: width - 20, height: 300)
            cell.addSubview(textView)
            
            cell.selectionStyle = .none
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.removeAllSubviews()
            
            var text = "Публикация записи от своего имени"
            
            if let id = Int(self.ownerID) {
                if id < 0 {
                    text = "Публикация записи от имени сообщества"
                }
            
                if postponed {
                    text = "\(text) \(postponedDate.toStringLastTime())"
                }
                let nameLabel = UILabel()
                nameLabel.tag = 250
                nameLabel.text = text
                nameLabel.font = UIFont(name: "Verdana", size: 13)
                nameLabel.textAlignment = .right
                nameLabel.isEnabled = false
                nameLabel.frame = CGRect(x: 20, y: 0, width: width - 40, height: 15)
                cell.addSubview(nameLabel)
            }
            
            cell.selectionStyle = .none
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.removeAllSubviews()
            
            if postponed && !setDate {
                let changeTimeButton = UIButton()
                changeTimeButton.tag = 250
                changeTimeButton.setTitle("Изменить время публикации", for: .normal)
                changeTimeButton.setTitleColor(changeTimeButton.tintColor, for: .normal)
                changeTimeButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)
                changeTimeButton.contentHorizontalAlignment = .right
                changeTimeButton.frame = CGRect(x: width - 320, y: 0, width: 300, height: 15)
                cell.addSubview(changeTimeButton)
                
                changeTimeButton.add(for: .touchUpInside) {
                    changeTimeButton.buttonTouched()
                    
                    self.setDate = true
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 7, section: 0), at: .bottom, animated: false)
                }
            }
            
            cell.selectionStyle = .none
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.removeAllSubviews()
            
            if postponed && setDate {
                let rect = CGRect(x: 10, y: 20, width: width - 20, height: 230)
                let datePicker = UIDatePicker(frame: rect)
                datePicker.tag = 250
                datePicker.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.3)
                datePicker.tintColor = vkSingleton.shared.mainColor
                
                let currentDate = Date()
                datePicker.date = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
                datePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
                
                if postponedDate == 0 {
                    datePicker.date = datePicker.minimumDate!
                } else {
                    datePicker.date = Date(timeIntervalSince1970: Double(postponedDate))
                }
                cell.addSubview(datePicker)
                
                let doneButton = UIButton()
                doneButton.tag = 250
                doneButton.setTitle("Сохранить время публикации", for: .normal)
                doneButton.setTitleColor(doneButton.tintColor, for: .normal)
                doneButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)
                doneButton.contentHorizontalAlignment = .right
                doneButton.frame = CGRect(x: width - 320, y: 0, width: 300, height: 15)
                cell.addSubview(doneButton)
                
                doneButton.add(for: .touchUpInside) {
                    doneButton.buttonTouched()
                    
                    self.postponedDate = Int(datePicker.date.timeIntervalSince1970)
                    self.setDate = false
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 6, section: 0), at: .bottom, animated: false)
                }
            }
            
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func configureAttachPanel() {
        attachPanel.delegate = self
        attachPanel.width = width - 20
        
        textView.text = ""
        
        if mode == .new {
            if let controller = delegate as? GroupProfileViewController, controller.groupProfile.count > 0 {
                let group = controller.groupProfile[0]
                
                if group.type == "page" {
                    suggested = true
                }
            }
        }
        
        if mode == .edit, let record = record {
            textView.text = record.text
            
            if record.postType == "postpone" {
                postponed = true
                postponedDate = record.date
            }
            
            if record.postType == "suggest" {
                suggested = true
                if vkSingleton.shared.adminGroups.filter({ $0.gid == abs(record.ownerID) }).count > 0 {
                    suggested = false
                }
            }
            
            if record.ownerID > 0 {
                if record.friendsOnly == 1 {
                    onlyFriends = true
                } else {
                    onlyFriends = false
                }
            } else if record.ownerID < 0 {
                if record.signerID > 0 {
                    addSigner = true
                }
            }
            
            for attach in record.attachments {
                if attach.photo.count > 0 {
                    attachPanel.attachArray.append(attach.photo[0])
                }
                
                if attach.video.count > 0 {
                    attachPanel.attachArray.append(attach.video[0])
                }
                
                if attach.doc.count > 0 {
                    attachPanel.attachArray.append(attach.doc[0])
                }
                
                if attach.link.count > 0 {
                    attachPanel.link = attach.link[0].url
                }
            }
        }
        
        attachPanel.removeFromSuperview()
        attachPanel.reconfigure()
        
        tableView.reloadData()
    }
    
    @IBAction func tapAttachButton(sender: UIBarButtonItem) {
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.ownerID = self.ownerID
        
        selectView.show()
    }
    
    @IBAction func tapPreviewButton(sender: UIBarButtonItem) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "RecordController") as! RecordController
        
        controller.type = "post"
        controller.delegate = self
        controller.preview = true
        
        var canPost = false
        
        if mode == .edit {
            let record = Record(json: JSON.null)
            
            print("fromID = \(self.record.fromID)")
            
            record.canComment = 0
            record.text = textView.text
            
            record.ownerID = self.record.ownerID
            record.fromID = self.record.fromID
            record.postType = self.record.postType
            record.date = self.record.date
            record.friendsOnly = self.record.friendsOnly
            record.signerID = self.record.signerID
            
            if record.postType == "postpone" {
                record.date = Int(Date().timeIntervalSince1970)
                record.postType = "post"
                
                if postponed {
                    record.postType = "postpone"
                    record.date = self.postponedDate
                }
                
                if record.ownerID > 0 {
                    if self.onlyFriends {
                        record.friendsOnly = 1
                    } else {
                        record.friendsOnly = 0
                    }
                } else if record.ownerID < 0 {
                    if addSigner, let signerID = Int(vkSingleton.shared.userID) {
                        record.signerID = signerID
                    } else {
                        record.signerID = 0
                    }
                }
            }
            
            if record.postType == "suggest" {
                record.date = Int(Date().timeIntervalSince1970)
                record.postType = "post"
                
                if vkSingleton.shared.adminGroups.filter({ $0.gid == abs(record.ownerID) }).count > 0 {
                    if addSigner {
                        record.signerID = self.record.fromID
                    } else {
                        record.signerID = 0
                    }
                    
                    record.fromID = self.record.ownerID
                    
                    if postponed {
                        record.postType = "postpone"
                        record.date = self.postponedDate
                    }
                }
            }
            
            
            record.attachments.removeAll(keepingCapacity: false)
            for object in attachPanel.attachArray {
                let attach = Attachment(json: JSON.null)
                
                if let photo = object as? Photo {
                    attach.type = "photo"
                    attach.photo.append(photo)
                }
                
                if let video = object as? Video {
                    attach.type = "video"
                    attach.video.append(video)
                }
                
                if let doc = object as? Document {
                    attach.type = "doc"
                    attach.doc.append(doc)
                }
                
                record.attachments.append(attach)
            }
            
            if attachPanel.link != "" {
                print(attachPanel.link)
                let attach = Attachment(json: JSON.null)
                attach.type = "link"
                
                let link = Link(json: JSON.null)
                link.title = "Внешняя ссылка"
                link.url = attachPanel.link
                
                attach.link.append(link)
                
                record.attachments.append(attach)
            }
            
            controller.record.append(record)
            
            if let vc = delegate as? RecordController {
                controller.users = vc.users
                controller.groups = vc.groups
            }
            
            if record.text == "" && record.attachments.count == 0 {
                self.showErrorMessage(title: "Новая запись", msg: "При публикации записи обязательно указать либо текст сообщения, либо вложить какой-либо объект (фотография, видеозапись, документ и т.д.)")
            } else {
                canPost = true
            }
        }
        
        if mode == .new {
            
            let record = Record(json: JSON.null)
            
            if let id = Int(ownerID) {
                record.ownerID = id
                
                if id > 0 {
                    if let fromID = Int(vkSingleton.shared.userID) {
                        record.fromID = fromID
                    }
                    
                    if onlyFriends {
                        record.friendsOnly = 1
                    }
                } else if id < 0 {
                    record.fromID = id
                    
                    if addSigner, let signerID = Int(vkSingleton.shared.userID) {
                        record.signerID = signerID
                    }
                }
            }
            
            record.canComment = 0
            record.text = textView.text
            
            if postponed {
                record.date = self.postponedDate
            } else {
                record.date = Int(Date().timeIntervalSince1970)
            }
            
            if suggested {
                if let id = Int(vkSingleton.shared.userID) {
                    record.fromID = id
                }
            }
            
            for object in attachPanel.attachArray {
                let attach = Attachment(json: JSON.null)
                
                if let photo = object as? Photo {
                    attach.type = "photo"
                    attach.photo.append(photo)
                }
                
                if let video = object as? Video {
                    attach.type = "video"
                    attach.video.append(video)
                }
                
                if let doc = object as? Document {
                    attach.type = "doc"
                    attach.doc.append(doc)
                }
                
                record.attachments.append(attach)
            }
            
            if attachPanel.link != "" {
                print(attachPanel.link)
                let attach = Attachment(json: JSON.null)
                attach.type = "link"
                
                let link = Link(json: JSON.null)
                link.title = "Внешняя ссылка"
                link.url = attachPanel.link
                
                attach.link.append(link)
                
                record.attachments.append(attach)
            }
            
            controller.record.append(record)
            
            if let vc = delegate as? ProfileViewController {
                controller.users = vc.wallProfiles
                controller.groups = vc.wallGroups
            } else if let vc = delegate as? GroupProfileViewController {
                controller.users = vc.wallProfiles
                controller.groups = vc.wallGroups
            }
            
            vkSingleton.shared.myProfile.photo100 = vkSingleton.shared.myProfile.maxPhotoURL
            controller.users.append(vkSingleton.shared.myProfile)
            
            if record.text == "" && record.attachments.count == 0 {
                self.showErrorMessage(title: "Новая запись", msg: "При публикации записи нужно обязательно указать либо текст сообщения, либо вложить какой-либо объект (фотографию, видеозапись, документ и т.д.)")
            } else {
                canPost = true
            }
        }
        
        if canPost {
            if let split = self.splitViewController {
                let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @objc func postponedSwitchValueChanged(sender: UISwitch) {
        postponed = sender.isOn
        setDate = false
        
        if postponed && postponedDate == 0 {
            let currentDate = Date()
            let newDate = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate)!
            postponedDate = Int(newDate.timeIntervalSince1970)
        }
        
        tableView.reloadData()
    }
    
    @objc func tapBarButton(sender: UIBarButtonItem) {
        
        
        if textView.text == "" && attachPanel.attachments == "" {
            self.showErrorMessage(title: "Новая запись", msg: "При публикации записи нужно обязательно указать либо текст сообщения, либо вложить какой-либо объект (фотографию, видеозапись, документ и т.д.)")
        } else {
            switch mode {
            case .new:
                publishPost()
            case .edit:
                editPost()
            }
        }
    }
}
