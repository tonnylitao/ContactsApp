//
//  UIImageViewEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

extension UIImageView {
    
    func setUrl(_ string: String?, placeholder: UIImage? = nil) {
        guard let string = string else {
            image = placeholder
            return
        }
        
        if let url = URL(string: string) {
            af.setImage(withURL: url, placeholderImage: placeholder)
        }else {
            image = placeholder
        }
    }
}
