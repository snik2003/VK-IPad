//
//  BrowserController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class BrowserController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var urlTextField: UITextField!
    
    var path: String = "https://geekbrains.ru/login"
    
    var isObserving = false
    
    var type = ""
    var artistID = 0
    var songID = 0
    var artist = ""
    var album = ""
    var song = ""
    var previewURL = ""
    var workURL = ""
    var avatarURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress.isHidden = true
        
        let vc = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        let width = vc.view.frame.width
        
        let configuration = WKWebViewConfiguration()
        let frameRect = CGRect(x: 10, y: 64 + 50, width: width - 20, height: self.view.bounds.height - 64 - 50 - 44)
        
        webView = WKWebView(frame: frameRect, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        //webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView)
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = barButton
        
        if let url = URL(string: path), url.host != nil {
            let request = URLRequest(url: url)
            urlTextField.text = path
            webView.load(request)
            
            if !isObserving {
                isObserving = true
                webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            }
        } else {
            showErrorMessage(title: "Ошибка", msg: "Некорректная ссылка:\n\(path)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isObserving {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            //print(webView.estimatedProgress)
            progress.progress = Float(webView.estimatedProgress);
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            urlTextField.text = url.absoluteString
        }
        progress.progress = 0.15
        progress.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progress.progress = 1
        progress.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progress.progress = 1
        progress.isHidden = true
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func reload(sender: UIBarButtonItem) {
        if let url = webView.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func webView(webView: WKWebView!, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError!) {
        
        self.progress.progress = 1
        self.progress.isHidden = true
        self.showErrorMessage(title: "Ошибка!", msg: error.localizedDescription)
    }
}
