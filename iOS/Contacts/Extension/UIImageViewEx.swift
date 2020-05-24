//
//  UIImageViewEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import AlamofireImage

extension UIImageView {
    
    func setUrl(_ string: String?) {
        guard let string = string else {
            image = nil
            return
        }
        
        if let url = URL(string: string) {
            af.setImage(withURL: url)
        }else {
            image = nil
        }
    }
}
