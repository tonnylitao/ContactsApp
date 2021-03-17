//
//  ProfileTableViewController.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var genderImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var cellLbl: UILabel!
    
    @IBOutlet weak var natLbl: UILabel!
    @IBOutlet weak var flagImgView: UIImageView!
    
    @IBOutlet weak var addrLbl: UILabel!
    
    var thumbnailImage: UIImage?
    var data: DBUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImgView.setUrl(data?.pictureLarge, placeholder: thumbnailImage)
        
        genderImgView.image = data?.genderImage
        nameLbl.attributedText = data?.nameOfAttributedString(fontSize: 20)
        
        dobLbl.text = data?.dayOfBirth?.localDateString
        
        emailLbl.text = data?.email
        phoneLbl.text = data?.phone
        cellLbl.text = data?.cell
        
        natLbl.text = data?.nationality
        flagImgView.image = data?.flagImage
        
        addrLbl.text = data?.address
    }

}
