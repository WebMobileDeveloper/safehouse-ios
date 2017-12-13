//
//  editphotoTableViewCell.swift
//  Safehouse
//
//  Created by Delicious on 10/3/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class editphotoTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
