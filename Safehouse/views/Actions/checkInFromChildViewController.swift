//
//  checkInFromChildViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/29/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import MapKit
class checkInFromChildViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTimeAndStreet: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var btnMoreInfo: UIButton!
    
    @IBAction func btnCloseClick(_ sender: Any) {
        user.seenCheckinRequestCheck()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnMoreInfoClick(_ sender: Any) {
      
        user.child_id = user.checkinRequests[0].child_id
        user.getChildInfo {
            user.getChildEvents { (result) in
                var newEvent:eventStruct!
                for event in result {
                    let eventStr:String = event["type"] as? String ?? ""
                    let checkin_id:String = event["checkin_id"] as? String ?? ""
                    if eventStr == "checkin" && checkin_id == user.checkinRequests[0].request_id{
                        newEvent = eventStruct()
                        newEvent.level = event["level"] as? Int ?? 1
                        newEvent.time = event["time"] as? TimeInterval ?? 0
                        let loc = event["location"] as? [String: Double] ?? ["lat":0,"long":0]
                        let lat = loc["lat"] ?? 0
                        let long = loc["long"] ?? 0
                        newEvent.location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        newEvent.photo_url = event["photo_url"] as? String ?? ""
                        newEvent.photo_text = event["photo_text"] as? String ?? ""
                        newEvent.checkin_id = event["checkin_id"] as? String ?? ""
                    }
                }
                if newEvent != nil {
                    if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "checkInDetailViewController") as? checkInDetailViewController {
                        viewController.event = newEvent
                        self.present(viewController, animated:true, completion:nil)
                    }
                }else{
                    showAlert(target: self, message: "You can't show deatil now, please try again later.")
                }
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = "Check-In From \(user.checkinRequests[0].child_name)"
        self.lblTimeAndStreet.text = ""
        if user.checkinRequests[0].photo_text != ""{
            lblMessage.text = user.checkinRequests[0].photo_text
        }else{
            lblMessage.isHidden = true
        }
        let photo_url = user.checkinRequests[0].photo_url
        if photo_url != "" {
            let url = URL(string:photo_url)
            let data = try? Data(contentsOf: url!)
            if data != nil{
                checkImage.image = UIImage(data: data!)
            }
        }
        reverseGeocoding(lat: user.checkinRequests[0].location.latitude, long: user.checkinRequests[0].location.longitude , completionHandler: { (pm) in
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
                        addressString = addressString + "Near " + pm.areasOfInterest![0]
                    }
                }
                if addressString == "" {
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality!
                    }
                }
            }
            let time: String = global_timeAgoSinceDate(time: user.checkinRequests[0].time, numericDates: true)
            if addressString != ""{
                self.lblTimeAndStreet.text = "\(time) at \(addressString)"
            }else{
                self.lblTimeAndStreet.text = "\(time)"
            }
        })
        
    }
    override func viewDidLayoutSubviews() {
        self.btnMoreInfo.layer.cornerRadius = self.btnMoreInfo.frame.height / 2
    }
}
