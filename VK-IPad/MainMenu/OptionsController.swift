//
//  OptionsController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 26.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox
import LocalAuthentication

class OptionsController: UITableViewController {
    
    var passwordOn = AppConfig.shared.passwordOn
    var passDigits = AppConfig.shared.passwordDigits
    var touchID = AppConfig.shared.touchID
    
    var changeStatus = false
    var width: CGFloat = 0
    
    let headers: [String] = [
        "Защита экрана паролем",
        "Push-уведомления",
        "Передавать текст сообщения",
        "Режим «Невидимка»",
        "Читать сообщения",
        "Отображать набор текста"]
    
    let descriptions: [String] = [
        "Вы можете установить пароль для доступа в приложение (простой пароль из 4 цифр)",
        "Чтобы получать уведомления о происходящих с вашим аакаунтом событиях, когда приложение закрыто, включите данный параметр.",
        "Передавать в пуш-уведомлении текст присланного сообщения. При выключенном параметре в уведомлении только будет содержаться, что такой-то пользователь отправил вам сообщение.",
        "Большинство функций в нашем приложении не будут менять ваш статус. Однако, есть такие функции, которые будут менять ваш статус на «онлайн» (например, просмотр новостей, отправка сообщения и некоторые другие). В этом случае наше приложение будет сразу выставлять вам статус «оффлайн», при этом ваше время последнего входа в ВКонтакте будет «заходил только что».",
        "Автоматически помечать сообщения как прочитанные при открытии конкретного диалога.",
        "Сообщать вашему собеседнику/сообществу о том, что вы набираете текст."]
    
    let checkBoxes: [String] = [
        "Новые сообщения",
        "Новые комментарии",
        "Заявки в друзья",
        "Ответы",
        "Лайки",
        "Упоминания",
        "Уведомления от сообществ",
        "Новые записи"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SwitchOptionCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(CheckOptionCell.self, forCellReuseIdentifier: "checkCell")
        
        let barButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        
        AppConfig.shared.readConfig()
        
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //AppConfig.shared.readConfig()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func touchAuthenticationAvailable() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        AppConfig.shared.passwordOn = passwordOn
        AppConfig.shared.passwordDigits = passDigits
        AppConfig.shared.touchID = touchID
        
        AppConfig.shared.saveConfig()
        if vkSingleton.shared.deviceToken != "" {
            if AppConfig.shared.pushNotificationsOn {
                registerDeviceOnPush()
            } else {
                unregisterDeviceOnPush()
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if passwordOn && touchAuthenticationAvailable() {
                return 2
            }
            return 1
        }
        if section == 1 {
            if AppConfig.shared.pushNotificationsOn {
                return checkBoxes.count + 1
            }
            return 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchOptionCell
            
            cell.delegate = self
            cell.header = headers[indexPath.section]
            cell.desc = descriptions[indexPath.section]
            cell.cellWidth = self.width
            
            if indexPath.section == 0 {
                if passwordOn {
                    cell.desc = ""
                }
            } else if indexPath.section == 1 {
                if AppConfig.shared.pushNotificationsOn {
                    cell.desc = ""
                }
            }
            
            return cell.getRowHeight()
        }
        
        if indexPath.section == 1 && indexPath.row == checkBoxes.count {
            return 50
        }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 15
        }
        if section == 1 {
            return 15
        }
        if section == 3 {
            return 15
        }
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 15
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchOptionCell
            
            cell.delegate = self
            cell.header = headers[indexPath.section]
            cell.desc = descriptions[indexPath.section]
            cell.cellWidth = self.width
            
            if indexPath.section == 0 {
                if passwordOn {
                    cell.desc = ""
                }
            } else if indexPath.section == 1 {
                if AppConfig.shared.pushNotificationsOn {
                    cell.desc = ""
                }
            }
            
            cell.configureCell()
            
            cell.selectionStyle = .none
            
            if indexPath.section == 0 {
                cell.optSwitch.isOn = passwordOn
            } else if indexPath.section == 1 {
                cell.optSwitch.isOn = AppConfig.shared.pushNotificationsOn
            } else if indexPath.section == 2 {
                cell.optSwitch.isOn = AppConfig.shared.showStartMessage
            } else if indexPath.section == 3 {
                cell.optSwitch.isOn = AppConfig.shared.setOfflineStatus
            } else if indexPath.section == 4 {
                cell.optSwitch.isOn = AppConfig.shared.readMessageInDialog
            } else if indexPath.section == 5 {
                cell.optSwitch.isOn = AppConfig.shared.showTextEditInDialog
            }
            cell.optSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "checkCell", for: indexPath) as! CheckOptionCell
                
                cell.desc = "Использовать TouchID"
                cell.configureCell()
                
                let tap = UITapGestureRecognizer()
                cell.descLabel.isUserInteractionEnabled = true
                cell.descLabel.addGestureRecognizer(tap)
                tap.add {
                    cell.optCheck.on = !cell.optCheck.on
                    self.touchID = cell.optCheck.on
                }
                
                cell.optCheck.on = touchID
                cell.optCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "checkCell", for: indexPath) as! CheckOptionCell
                
                cell.desc = checkBoxes[indexPath.row - 1]
                cell.configureCell()
                
                let tap = UITapGestureRecognizer()
                cell.descLabel.isUserInteractionEnabled = true
                cell.descLabel.addGestureRecognizer(tap)
                
                if indexPath.row == 1 {
                    cell.optCheck.on = AppConfig.shared.pushNewMessage
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushNewMessage = cell.optCheck.on
                    }
                } else if indexPath.row == 2 {
                    cell.optCheck.on = AppConfig.shared.pushComment
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushComment = cell.optCheck.on
                    }
                } else if indexPath.row == 3 {
                    cell.optCheck.on = AppConfig.shared.pushNewFriends
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushNewFriends = cell.optCheck.on
                    }
                } else if indexPath.row == 4 {
                    cell.optCheck.on = AppConfig.shared.pushNots
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushNots = cell.optCheck.on
                    }
                } else if indexPath.row == 5 {
                    cell.optCheck.on = AppConfig.shared.pushLikes
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushLikes = cell.optCheck.on
                    }
                } else if indexPath.row == 6 {
                    cell.optCheck.on = AppConfig.shared.pushMentions
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushMentions = cell.optCheck.on
                    }
                } else if indexPath.row == 7 {
                    cell.optCheck.on = AppConfig.shared.pushFromGroups
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushFromGroups = cell.optCheck.on
                    }
                } else if indexPath.row == 8 {
                    cell.optCheck.on = AppConfig.shared.pushNewPosts
                    tap.add {
                        cell.optCheck.on = !cell.optCheck.on
                        AppConfig.shared.pushNewPosts = cell.optCheck.on
                    }
                }
                cell.optCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        return cell
    }
    
    @objc func valueChangedSwitch(sender: UISwitch) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            
            if indexPath.section == 0 {
                passwordOn = sender.isOn
                tableView.reloadData()
            }
            
            if indexPath.section == 1 {
                AppConfig.shared.pushNotificationsOn = sender.isOn
                tableView.reloadData()
            }
            
            if indexPath.section == 2 {
                AppConfig.shared.showStartMessage = sender.isOn
            }
            
            if indexPath.section == 3 {
                AppConfig.shared.setOfflineStatus = sender.isOn
            }
            
            if indexPath.section == 4 {
                AppConfig.shared.readMessageInDialog = sender.isOn
            }
            
            if indexPath.section == 5 {
                AppConfig.shared.showTextEditInDialog = sender.isOn
            }
        }
    }
    
    @objc func checkBoxValueChanged(sender: BEMCheckBox) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            if indexPath.section == 0 && indexPath.row == 1 {
                touchID = sender.on
            }
            
            if indexPath.section == 1 {
                switch indexPath.row {
                case 1:
                    AppConfig.shared.pushNewMessage = sender.on
                case 2:
                    AppConfig.shared.pushComment = sender.on
                case 3:
                    AppConfig.shared.pushNewFriends = sender.on
                case 4:
                    AppConfig.shared.pushNots = sender.on
                case 5:
                    AppConfig.shared.pushLikes = sender.on
                case 6:
                    AppConfig.shared.pushMentions = sender.on
                case 7:
                    AppConfig.shared.pushFromGroups = sender.on
                case 8:
                    AppConfig.shared.pushNewPosts = sender.on
                default:
                    break
                }
            }
            
            tableView.reloadData()
        }
    }
}
