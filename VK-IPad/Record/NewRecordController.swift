//
//  NewRecordController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var attachButton: UIBarButtonItem!
    @IBOutlet weak var previewButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
        let barButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapBarButton(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        
        configureAttachPanel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return attachPanel.frame.height
        case 1:
            return 220
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.removeAllSubviews()
        
        switch indexPath.row {
        case 1:
            textView.tag = 250
            textView.layer.cornerRadius = 6
            textView.layer.borderWidth = 0.8
            textView.layer.borderColor = UIColor.darkGray.cgColor
            textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            
            textView.text = ""
            if mode == .edit, let record = record {
                textView.text = record.text
            }
            
            textView.font = UIFont(name: "Verdana", size: 15)
            textView.frame = CGRect(x: 10, y: 10, width: width - 20, height: 200)
            cell.addSubview(textView)
        default:
            break
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func configureAttachPanel() {
        attachPanel.delegate = self
        attachPanel.width = width - 20
        
        if mode == .edit, let record = record {
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
            }
        }
        
        attachPanel.removeFromSuperview()
        attachPanel.reconfigure()
        
        tableView.reloadData()
    }
    
    @IBAction func tapAttachButton(sender: UIBarButtonItem) {
        
        let selectView = SelectAttachPanel()
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.ownerID = self.ownerID
        selectView.show()
    }
    
    @IBAction func tapPreviewButton(sender: UIBarButtonItem) {
        
    }
    
    @objc func tapBarButton(sender: UIBarButtonItem) {
        if mode == .new {
            
            
        } else if mode == .edit {
            
            
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
