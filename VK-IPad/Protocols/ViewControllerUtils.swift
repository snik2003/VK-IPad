//
//  ViewControllerUtils.swift
//  VK-total
//
//  Created by Сергей Никитин on 17.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ViewControllerUtils {
    
    private static var container: UIView = UIView()
    private static var loadingView: UIView = UIView()
    private static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    func showActivityIndicator(uiView: UIView) {
        ViewControllerUtils.container.frame = uiView.frame
        ViewControllerUtils.container.center = uiView.center
        ViewControllerUtils.container.backgroundColor = UIColor.clear
        
        ViewControllerUtils.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        ViewControllerUtils.loadingView.center = uiView.center
        ViewControllerUtils.loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        ViewControllerUtils.loadingView.clipsToBounds = true
        ViewControllerUtils.loadingView.layer.cornerRadius = 10
        
        ViewControllerUtils.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        ViewControllerUtils.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        //ViewControllerUtils.activityIndicator.color = UIColor.black
        ViewControllerUtils.activityIndicator.center = CGPoint(x: ViewControllerUtils.loadingView.frame.size.width / 2, y: ViewControllerUtils.loadingView.frame.size.height / 2);
        
        ViewControllerUtils.loadingView.addSubview(ViewControllerUtils.activityIndicator)
        ViewControllerUtils.container.addSubview(ViewControllerUtils.loadingView)
        uiView.addSubview(ViewControllerUtils.container)
        ViewControllerUtils.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        ViewControllerUtils.activityIndicator.stopAnimating()
        ViewControllerUtils.container.removeFromSuperview()
    }
    
    func showActivityIndicator2(controller: UIViewController) {
        
        if let split = controller.navigationController?.splitViewController,
            let detail = split.viewControllers[0].childViewControllers[0] as? MenuViewController {
            
            let width = split.view.bounds.width - detail.view.bounds.width
            let height = split.view.bounds.height
            let centerPoint = CGPoint(x: width/2, y: height/2 - 20)
            
            ViewControllerUtils.container.frame = CGRect(x: 0, y: 0, width: width, height: height)
            ViewControllerUtils.container.center = centerPoint
            ViewControllerUtils.container.backgroundColor = .clear
            
            ViewControllerUtils.loadingView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
            ViewControllerUtils.loadingView.center = centerPoint
            ViewControllerUtils.loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
            ViewControllerUtils.loadingView.clipsToBounds = true
            ViewControllerUtils.loadingView.layer.cornerRadius = 10
            
            let label1 = UILabel()
            label1.setActivityText(text: "Подождите!")
            label1.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
            
            let label2 = UILabel()
            label2.setActivityText(text: "Идет загрузка данных")
            label2.frame = CGRect(x: 0, y: 70, width: 200, height: 30)
            
            ViewControllerUtils.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
            ViewControllerUtils.activityIndicator.activityIndicatorViewStyle = .whiteLarge
            ViewControllerUtils.activityIndicator.center = CGPoint(x: ViewControllerUtils.loadingView.frame.size.width / 2, y: ViewControllerUtils.loadingView.frame.size.height / 2);
            
            ViewControllerUtils.loadingView.addSubview(label1)
            ViewControllerUtils.loadingView.addSubview(ViewControllerUtils.activityIndicator)
            ViewControllerUtils.loadingView.addSubview(label2)
            
            ViewControllerUtils.container.addSubview(ViewControllerUtils.loadingView)
            controller.view.addSubview(ViewControllerUtils.container)
            ViewControllerUtils.activityIndicator.startAnimating()
        }
    }
    
    func UIColorFromHex(rgbValue: UInt32, alpha: Double=1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
}

extension UIView {
    var visibleRect: CGRect {
        guard let superview = superview else { return frame }
        return frame.intersection(superview.bounds)
    }
}

extension UILabel {
    func setActivityText(text: String) {
        
        self.text = text
        self.textAlignment = .center
        self.font = UIFont(name: "Verdana", size: 15)
        self.textColor = .white
    }
}
