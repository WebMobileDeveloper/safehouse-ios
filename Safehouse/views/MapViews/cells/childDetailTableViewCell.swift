//
//  ChildDetailTableViewCell.swift
//  Safehouse
//
//  Created by Delicious on 9/26/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class childDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var batteryImage: UIImageView!
    @IBOutlet weak var batteryPercent: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var onOffStateLabel: UILabel!
    @IBOutlet weak var lblJustNow: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
