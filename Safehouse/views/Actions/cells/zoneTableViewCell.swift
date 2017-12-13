//
//  zoneTableViewCell.swift
//  Safehouse
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class zoneTableViewCell: UITableViewCell {

    @IBOutlet weak var lblZoneName: UILabel!
    @IBOutlet weak var zoneDetailButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
