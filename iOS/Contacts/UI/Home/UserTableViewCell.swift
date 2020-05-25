//
//  UserTableViewCell.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import UIKit
import AlamofireImage

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var titleAndNameLbl: UILabel!
    
    @IBOutlet weak var flagImgView: UIImageView!
    
    @IBOutlet weak var genderImgView: UIImageView?
    @IBOutlet weak var birthdayLbl: UILabel?
    
    var data: DBUser? {
        didSet {
            avatarImgView.setUrl(data?.pictureThumbnail)
            titleAndNameLbl.attributedText = data?.nameOfAttributedString(fontSize: 18)
            
            genderImgView?.image = data?.genderImage
            
            flagImgView?.image = data?.flagImage
            birthdayLbl?.text = data?.dayOfBirth?.localDateString
        }
    }

}

extension UserTableViewCell: TableViewCell { }
