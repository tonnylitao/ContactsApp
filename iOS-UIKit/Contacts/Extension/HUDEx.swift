//
//  HUDEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import MBProgressHUD
import SwiftInKotlinStyle

extension UIView {
    
    func showHUD() -> MBProgressHUD {
        
        let hud = MBProgressHUD.showAdded(to: self, animated: false)
        hud.isUserInteractionEnabled = false
        
        return hud
    }
    
    func showHUDMessage(_ message: String) {
        
        MBProgressHUD.showAdded(to: self, animated: true).also {
            $0.mode = .customView
            
            $0.isUserInteractionEnabled = false
            
            $0.isSquare = true
            $0.label.text = message
            $0.label.numberOfLines = 0
            $0.hide(animated: true, afterDelay: 2.0)
        }
    }
}

extension MBProgressHUD {
    
    func hideWith(_ err: AppError?) {
        
        if let msg = err?.humanReadableMessage {
            self.hideWith(msg)
        }else {
            self.hide(animated: true)
        }
    }
    
    func hideWith(_ message: String) {
        
        mode = .text
        label.text = message
        label.numberOfLines = 0
        hide(animated: true, afterDelay: 3.0)
    }
}
