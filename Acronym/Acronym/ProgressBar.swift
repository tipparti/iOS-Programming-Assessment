//
//  ProgressBar.swift
//  Acronym
//
//  Created by Naina Sai Tipparti on 3/10/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//


import UIKit
import Foundation
import MBProgressHUD

class ProgressBar: NSObject {
    // MARK: Load MBProgressHUD
    class func show(message:String = "Loading...", delegate: UIViewController) {
        var load : MBProgressHUD = MBProgressHUD()
        load = MBProgressHUD.showAdded(to: delegate.view, animated: true)
        if message.characters.count > 0 {
            load.label.text = message
        }
        load.backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
        load.backgroundView.color = UIColor.init(white: 1.0, alpha: 0.1)
        load.mode = MBProgressHUDMode.indeterminate
        
    }
    // MARK: Hide MBProgressHUD
    class func hide(delegate:UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: delegate.view, animated: true)
        }
    }
}
