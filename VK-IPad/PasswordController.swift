//
//  PasswordController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 27.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SmileLock

class PasswordController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordStackView: UIStackView!
    var passwordContainerView = PasswordContainerView()
    
    var newPass1 = ""
    var newPass2 = ""
    var delegate: OptionsController!
    
    let kPasswordDigit = 4
    let tintColor = UIColor.white
    let viewColor = vkSingleton.shared.mainColor
    var state = "login"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        
        passwordContainerView.deleteButtonLocalizedTitle = ""
        passwordContainerView.deleteButton.setImage(UIImage(named: "delete-button"), for: .normal)
        passwordContainerView.deleteButton.imageView?.contentMode = .scaleAspectFit
        passwordContainerView.deleteButton.imageView?.clipsToBounds = true
        passwordContainerView.deleteButton.tintColor = tintColor
        
        titleLabel.textColor = tintColor
        
        self.view.backgroundColor = viewColor.withAlphaComponent(0.8)
        for view in passwordContainerView.passwordInputViews {
            view.circleBackgroundColor = viewColor.withAlphaComponent(0.8)
        }
        
        passwordContainerView.tintColor = tintColor
        passwordContainerView.highlightedColor = viewColor.withAlphaComponent(0.8)
        
        if state == "login" {
            titleLabel.text = "Для доступа в приложение введите пароль:"
            passwordContainerView.touchAuthenticationEnabled = AppConfig.shared.touchID
        } else if state == "change" {
            titleLabel.text = "Придумайте и введите новый пароль:"
            passwordContainerView.touchAuthenticationEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if passwordContainerView.touchAuthenticationEnabled {
            passwordContainerView.touchAuthenticationButton.sendActions(for: .touchUpInside)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension PasswordController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if state == "login" {
            if validation(input) {
                validationSuccess()
            } else {
                validationFail()
            }
        } else if state == "change" {
            if newPass1 == "" {
                newPass1 = input
                titleLabel.text = "Для надежности введите новый пароль ещё раз:"
                passwordContainerView.clearInput()
            } else {
                newPass2 = input
                if newPass1 == newPass2 {
                    AppConfig.shared.passwordOn = delegate.passwordOn
                    AppConfig.shared.passwordDigits = newPass1
                    AppConfig.shared.touchID = delegate.touchID
                    
                    AppConfig.shared.saveConfig()
                    if vkSingleton.shared.deviceToken != "" {
                        if AppConfig.shared.pushNotificationsOn {
                            registerDeviceOnPush()
                        } else {
                            unregisterDeviceOnPush()
                        }
                    }
                    validationSuccess()
                } else {
                    passwordContainerView.wrongPassword()
                    newPass1 = ""
                    titleLabel.text = "Пароли не совпадают. Введите новый пароль:"
                    passwordContainerView.clearInput()
                }
            }
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasswordController {
    func validation(_ input: String) -> Bool {
        return input == AppConfig.shared.passwordDigits
    }
    
    func validationSuccess() {
        dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        passwordContainerView.wrongPassword()
    }
}
