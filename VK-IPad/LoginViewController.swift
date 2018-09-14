//
//  LoginViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import Popover
import RealmSwift

class LoginViewController: UIViewController {

    var webview: WKWebView!
    
    var accounts: [vkAccount] = []
    
    var changeAccount = false
    var exitAccount = false
    var checkPassword = false
    
    let userDefaults = UserDefaults.standard

    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cleanCookies()
        AppConfig.shared.readConfig()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if exitAccount {
            if self.getNumberOfAccounts() > 0 {
                changeAccountForm()
            } else {
                vkAutorize()
            }
        } else {
            if changeAccount {
                if vkSingleton.shared.userID == "" {
                    vkAutorize()
                } else {
                    vkSingleton.shared.accessToken = getAccessTokenFromRealm(userID: Int(vkSingleton.shared.userID)!)
                    
                    
                    if vkSingleton.shared.accessToken != "" {
                        performSegue(withIdentifier: "goProfile", sender: nil)
                    } else {
                        vkAutorize()
                    }
                }
            } else {
                if let userID = userDefaults.string(forKey: "vkUserID") {
                    vkSingleton.shared.userID = userID
                
                    AppConfig.shared.readConfig()
                    
                    if AppConfig.shared.passwordOn && !checkPassword {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordController") as! PasswordController
                        vc.state = "login"
                        present(vc, animated: true)
                        checkPassword = true
                    }
                    
                    if let userID = Int(vkSingleton.shared.userID) {
                        vkSingleton.shared.accessToken = getAccessTokenFromRealm(userID: userID)
                    }
            
                    if vkSingleton.shared.accessToken != "" {
                        performSegue(withIdentifier: "goProfile", sender: nil)
                    } else {
                        vkAutorize()
                    }
                } else {
                    vkAutorize()
                }
            }
        }
        
        exitAccount = false
        changeAccount = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func vkAutorize() {
        webview = WKWebView(frame: self.view.frame)
        webview.navigationDelegate = self
        webview.backgroundColor = UIColor.white
        self.view.addSubview(webview)
        
        var urlComponents = URLComponents()
            
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        
        if let appID = Int(getFreeAppID()), appID > 0 {
            vkSingleton.shared.userAppID = appID
        
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: "\(appID)"),
                URLQueryItem(name: "display", value: "mobile"),
                URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
                URLQueryItem(name: "scope", value: "friends, photos, audio, video, pages, status, notes, messages, wall, docs, groups, notifications, offline"),
                URLQueryItem(name: "response_type", value: "token"),
                URLQueryItem(name: "v", value: vkSingleton.shared.version)
            ]
            
            let request = URLRequest(url: urlComponents.url!)
            webview.load(request)
        }
    }
    
    func vkLogout() {
        cleanCookies()
        
        deleteAccountFromRealm(userID: Int(vkSingleton.shared.userID)!)
        UserDefaults.standard.removeObject(forKey: "\(vkSingleton.shared.userAppID)")
        
        vkSingleton.shared.accessToken = ""
        vkSingleton.shared.userID = ""
        vkSingleton.shared.userAppID = 0
    }

    func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    @IBAction func logoutVKsegue(unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "logoutVK" {
            
            vkLogout()
            var webview_new = WKWebView() {
                didSet{
                    webview_new.navigationDelegate = self
                }
            }
            vkSingleton.shared.accessToken = ""
            vkSingleton.shared.userID = ""
            exitAccount = true
        }
        
        if unwindSegue.identifier == "addAccountVK" {
            cleanCookies()
            var webview_new = WKWebView() {
                didSet{
                    webview_new.navigationDelegate = self
                }
            }
            vkSingleton.shared.accessToken = ""
            vkSingleton.shared.userID = ""
            changeAccount = true
        }
    }
    
    func readAccountsFromRealm() {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            let accounts = realm.objects(vkAccount.self)
            
            self.accounts = Array(accounts)
        } catch {
            print(error)
        }
    }
    
    func changeAccountForm() {
        
        readAccountsFromRealm()
        
        vkSingleton.shared.accessToken = accounts[0].token
        vkSingleton.shared.userID = "\(accounts[0].userID)"
        userDefaults.set(vkSingleton.shared.userID, forKey: "vkUserID")
        
        performSegue(withIdentifier: "goProfile", sender: nil)
    }
}

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment  else {
            decisionHandler(.allow)
            
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        if let token = params["access_token"], let id = params["user_id"] {
            vkSingleton.shared.accessToken = token
            vkSingleton.shared.userID = id
            userDefaults.set(vkSingleton.shared.userID, forKey: "vkUserID")
            userDefaults.set(true, forKey: "\(vkSingleton.shared.userAppID)")
            
            performSegue(withIdentifier: "goProfile", sender: nil)
            
            decisionHandler(.cancel)
            webView.removeFromSuperview()
        } else {
            decisionHandler(.cancel)
            webView.removeFromSuperview()
            
            vkAutorize()
        }
    }
    
    func getAppID() -> String {
        
        var result = ""
        let count = vkSingleton.shared.vkAppID.count
        
        if count > 0 {
            result = vkSingleton.shared.vkAppID[count - 1]
        
            let num = getNumberOfAccounts()
            if num < count {
                result = vkSingleton.shared.vkAppID[num]
            }
        }
        
        return result
    }
    
    func getFreeAppID() -> String {
        
        var result = ""
        let count = vkSingleton.shared.vkAppID.count
        
        if count > 0 {
            result = vkSingleton.shared.vkAppID[count - 1]
            for appID in vkSingleton.shared.vkAppID {
                if !UserDefaults.standard.bool(forKey: appID) {
                    result = appID
                    break
                }
            }
        }
        
        return result
    }
}
