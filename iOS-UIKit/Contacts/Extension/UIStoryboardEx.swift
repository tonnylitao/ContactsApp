//
//  UIStoryboardEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    static let main = UIStoryboard(name: "Main", bundle: nil)
}

extension UIStoryboard {
    
    func viewController(_ identifier: String) -> UIViewController {
        return instantiateViewController(withIdentifier: identifier)
    }
}
