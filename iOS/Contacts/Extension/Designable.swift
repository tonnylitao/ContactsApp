//
//  Designable.swift
//  Contacts
//
//  Created by TonnyLi on 19/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DesignableImageView: UIImageView {}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
   
}
