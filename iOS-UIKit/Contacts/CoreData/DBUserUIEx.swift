//
//  DBUser.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import UIKit
import FlagKit


extension DBUser {
    
    func nameOfAttributedString(fontSize: CGFloat) -> NSAttributedString {
        
        let string = NSMutableAttributedString(string: "#\(uniqueId) ", attributes:[
            .font: UIFont.systemFont(ofSize: fontSize-2),
            .foregroundColor: UIColor(white: 105.0/255.0, alpha: 1 )
        ])
        
        if let title = self.title {
            string.append(NSAttributedString(string: "\(title). ", attributes:[
                .font: UIFont.systemFont(ofSize: fontSize-2),
                .foregroundColor: UIColor(white: 105.0/255.0, alpha: 1 )
            ]))
        }
        
        let name = [firstName, lastName].compactMap { $0 }
        
        if name.count > 0 {
            string.append(NSAttributedString(string: name.joined(separator: " "), attributes: [.font: UIFont.systemFont(ofSize: fontSize)]))
        }
        
        return string
    }
    
    var genderImage: UIImage? {
        if let value = gender,
            let _ = Gender(rawValue: value) {
            return UIImage(named: "ic_\(value)")
        }
        return nil
    }
    
    var flagImage: UIImage? {
        guard let countryCode = nationality else { return nil }
        
        let flag = Flag(countryCode: countryCode)
        return flag?.originalImage
    }
}
