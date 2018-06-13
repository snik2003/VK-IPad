//
//  LoginViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {

    var webview: WKWebView!
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vkAutorize()
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
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "\(vkSingleton.shared.vkAppID[0])"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "friends, photos, audio, video, pages, status, notes, messages, wall, docs, groups, notifications, offline"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: vkSingleton.shared.version)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        print(request)
        webview.load(request)
    }
    
    func vkLogout() {
        cleanCookies()
        
        vkSingleton.shared.accessToken = ""
        vkSingleton.shared.userID = ""
    }

    func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
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
            
            //performSegue(withIdentifier: "goTabbar", sender: nil)
            print("autorize success")
            
            decisionHandler(.cancel)
            webView.removeFromSuperview()
        } else {
            decisionHandler(.cancel)
            webView.removeFromSuperview()
            
            vkAutorize()
        }
    }
}
