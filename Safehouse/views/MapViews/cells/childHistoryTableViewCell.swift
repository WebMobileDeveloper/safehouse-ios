//
//  childHistoryTableViewCell.swift
//  Safehouse
//
//  Created by Delicious on 9/26/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class childHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventDegreeImageView: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventPosition: UILabel!
    @IBOutlet weak var eventDetailBtn: UIButton!
    
    
    var cellData:eventStruct = eventStruct()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {

        
        // Configure the view for the selected state
    }
    
    func configCell(initData: eventStruct) {
        cellData = initData
        eventImageView.image = cellData.image()
        eventDegreeImageView.backgroundColor = cellData.degreeColor()
        eventLabel.text = cellData.eventTitle()
        eventTimeLabel.text = cellData.timeAgoSinceDate()
        //display street
        
        reverseGeocoding(lat: cellData.location.latitude, long: cellData.location.longitude , completionHandler: { (pm) in
            var addressString : String = ""
            if let pm = pm{
                if pm.subThoroughfare != nil {
                    addressString = addressString + pm.subThoroughfare! + " "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare!
                }
                if addressString == "" {
                    if pm.areasOfInterest != nil {
                        addressString = addressString + pm.areasOfInterest![0]
                    }
                }
                if addressString == "" {
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality!
                    }
                }
            }
            self.eventPosition.text = addressString
        })
    }
    
}
