//
//  AddNewTopicController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class AddNewTopicController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: UIViewController!
    var attachPanel = AttachPanel()
    var selectView = SelectAttachPanel()
    
    var titleView = UITextView()
    var textView = UITextView()
    
    var groupID = ""
    var fromGroup = false
    
    var width: CGFloat = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attachButton: UIBarButtonItem!
    
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
        
        if titleView.isFirstResponder {
            tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: false)
        } else if textView.isFirstResponder {
            tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: false)
        }
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
    
    @objc func tapBarButton(sender: UIBarButtonItem) {
        
        self.hideKeyboard()
        
        var ready = true
        
        if titleView.text == "" {
            ready = false
            self.showErrorMessage(title: "Новое обсуждение", msg: "При создании нового обсуждения нужно обязательно ввести название темы обсуждения.")
        } else {
            if textView.text == "" && attachPanel.attachments == "" {
                ready = false
                self.showErrorMessage(title: "Новое обсуждение", msg: "При создании нового обсуждения нужно обязательно либо ввести текст первого сообщения в обсуждении, либо вложить какой-либо объект (фотографию, видеозапись, документ и т.д.)")
            }
        }
        
        if ready {
            self.addTopic()
        }
    }
    
    func configureAttachPanel() {
        attachPanel.delegate = self
        attachPanel.width = width - 20
        
        attachPanel.reconfigure()
        tableView.reloadData()
    }
    
    @IBAction func tapAttachButton(sender: UIBarButtonItem) {
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.ownerID = "-\(self.groupID)"
        
        selectView.show()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return attachPanel.frame.height + 5
        case 1:
            return 40
        case 2:
            return 90
        case 3:
            return 200
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
            
            
            cell.delegate = self
            cell.header = "Создать обсуждение от имени сообщества"
            cell.desc = ""
            cell.cellWidth = self.width
            cell.optSwitch.isOn = fromGroup
            cell.optSwitch.add(for: .valueChanged) {
                self.fromGroup = cell.optSwitch.isOn
            }
            cell.configureCell()
            
            cell.selectionStyle = .none
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.removeAllSubviews()
            
            let label = UILabel()
            label.tag = 250
            label.text = "Название темы обсуждения:"
            label.font = UIFont(name: "Verdana-Bold", size: 13)
            label.textColor = vkSingleton.shared.mainColor
            label.textAlignment = .center
            label.frame = CGRect(x: 10, y: 5, width: width - 20, height: 25)
            cell.addSubview(label)
            
            titleView.tag = 250
            titleView.layer.cornerRadius = 6
            titleView.layer.borderWidth = 0.8
            titleView.layer.borderColor = UIColor.darkGray.cgColor
            titleView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            
            titleView.font = UIFont(name: "Verdana-Bold", size: 14)
            titleView.textAlignment = .center
            titleView.frame = CGRect(x: 10, y: 30, width: width - 20, height: 60)
            cell.addSubview(titleView)
            
            cell.selectionStyle = .none
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.removeAllSubviews()
            
            let label = UILabel()
            label.tag = 250
            label.text = "Текст первого сообщения в обсуждении:"
            label.font = UIFont(name: "Verdana-Bold", size: 13)
            label.textAlignment = .center
            label.textColor = vkSingleton.shared.mainColor
            label.frame = CGRect(x: 10, y: 5, width: width - 20, height: 25)
            cell.addSubview(label)
            
            textView.tag = 250
            textView.layer.cornerRadius = 6
            textView.layer.borderWidth = 0.8
            textView.layer.borderColor = UIColor.darkGray.cgColor
            textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            
            textView.font = UIFont(name: "Verdana", size: 15)
            textView.frame = CGRect(x: 10, y: 30, width: width - 20, height: 165)
            cell.addSubview(textView)
            
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
}
