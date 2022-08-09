//
//  UIViewcontroller+Extension.swift
//  Translate Picture
//
//  Created by JKSOL on 12/02/20.
//  Copyright © 2020 JK Sol. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

var activityIndicatorView : NVActivityIndicatorView!
var subview : UIView!
extension UIViewController {
    
    func showLoader() {
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: UIColor.init(named: "Color"), padding: 0)
        //UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        self.view.addSubview(activityIndicatorView)
        
        let originpointx = (self.view.frame.size.width - activityIndicatorView.frame.size.width) / 2
        let originpointy = (self.view.frame.size.height - activityIndicatorView.frame.size.height) / 2
        
        activityIndicatorView.frame = CGRect(x: originpointx , y: originpointy, width: 50, height: 50)
        
        activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func dismissLoader(){
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
}
