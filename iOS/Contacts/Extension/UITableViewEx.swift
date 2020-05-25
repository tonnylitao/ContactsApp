//
//  UITableViewEx.swift
//  Contacts
//
//  Created by TonnyLi on 25/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewCell {
    static var identifier: String { get }
}

extension TableViewCell {
    static var identifier: String {
        return "cell"
    }
}

/* --------------------------------------------- */

extension TableViewCell where Self: UITableViewCell {
    
    static func dequeueReusableCellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: Self.identifier, for: indexPath) as! Self
    }
}
