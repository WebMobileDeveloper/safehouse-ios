//
//  Global.swift
//  Safehouse
//
//  Created by Delicious on 9/21/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import Foundation
import UIKit
import MapKit


let KEY_FAMILY_ID = "KEY_FAMILY_ID"
let KEY_NAME = "KEY_NAME"
let KEY_EMAIL = "KEY_EMAIL"
let KEY_PASSWORD = "KEY_PASSWORD"
let KEY_FACEBOOK_ID = "KEY_FACEBOOK_ID"
let KEY_SIGNUP_FINISHED = "KEY_SIGNUP_FINISHED"
var user:UserClass = UserClass()

let MAX_UPLOAD_IMAGE_SIZE = 100 * 1024
let PROFILE_IMAGE_WIDTH:CGFloat = 200


let DBURL = "https://safehouse-488e5.firebaseio.com/"


class Global{
    static let screenSize = UIScreen.main.bounds
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let Y_ratio = UIScreen.main.bounds.height / 667
    static let X_ratio = UIScreen.main.bounds.width / 375
}

struct ShortCodeGenerator {
    
    private static let base62chars = [Character]("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private static let maxBase : UInt32 = 36
    
    static func getCode(withBase base: UInt32 = maxBase, length: Int) -> String {
        var code = ""
        for _ in 0..<length {
            let random = Int(arc4random_uniform(min(base, maxBase)))
            code.append(base62chars[random])
        }
        return code
    }
}

// MARK:- degreesToRadians
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
extension Double {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(Double.pi) / 180.0
    }
}

extension UILabel {
    func createCopy() -> UILabel {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: archivedData) as! UILabel
    }
}
extension UIViewController{
    
    func startActivityIndicator(
        style: UIActivityIndicatorViewStyle = .whiteLarge,
        location: CGPoint? = nil) {
        let loc = location ?? self.view.center
      
        DispatchQueue.main.async {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            
            activityIndicator.tag = 100  //self.activityIndicatorTag
            
            //Set the location
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            
            //Start animating and add the view
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func stopActivityIndicator() {
        
        //Again, we need to ensure the UI is updated from the main thread!
        
        DispatchQueue.main.async {
            //Here we find the `UIActivityIndicatorView` and remove it from the view
            
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == 100 }).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
}
func showAlert(target: UIViewController, message: String, title:String = "Alert", hander:@escaping ()->Void = {}) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        hander()
    }))
    var subView = alert.view.subviews.first!
    subView = subView.subviews.first!
    subView = subView.subviews.last!
    //alert.view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    subView.backgroundColor = UIColor.white
    target.present(alert, animated: true, completion: nil)
}


func showChoiceAlert(target:UIViewController){
    let choiceAlert = UIAlertController(title: "Select type", message: "Select your profile image type.", preferredStyle: UIAlertControllerStyle.alert)
    
    choiceAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction!) in
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true;
        imagePickerController.delegate = target as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        target.present(imagePickerController, animated: true, completion: nil)
    }))
    
    choiceAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.delegate = target as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        target.present(imagePickerController, animated: true, completion: nil)
    }))
    target.present(choiceAlert, animated: true, completion: nil)
}
func reverseGeocoding(lat:Double, long: Double, completionHandler: @escaping (CLPlacemark?)
    -> Void ) {
    // Use the last reported location.
    
    
    // Look up the location and pass it to the completion handler
    let lastLocation = CLLocation(latitude: lat, longitude: long)
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
        if error == nil {
            let pm = placemarks! as [CLPlacemark]
            if pm.count > 0 {
                let pm = placemarks![0]
                completionHandler(pm)
            }else{
                completionHandler(nil)
            }
        }
        else {
            completionHandler(nil)
        }
    })
    
}

//func reverseGeocoding(lat:Double, long: Double, completion: @escaping (_ placemark:CLPlacemark)->()) {
//    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
//    //let lat: Double = location.coordinate.latitude
//    //21.228124
//    //let lon: Double = location.coordinate.longitude
//    //72.833770
//    let ceo: CLGeocoder = CLGeocoder()
//    center.latitude = lat
//    center.longitude = long
//
//    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
//
//
//    ceo.reverseGeocodeLocation(loc, completionHandler:
//        {(placemarks, error) in
//            if (error != nil)
//            {
//                print("reverse geodcode fail: \(error!.localizedDescription)")
//            }
//            let pm = placemarks! as [CLPlacemark]
//
//            if pm.count > 0 {
//                let pm = placemarks![0]
//                completion(pm)
//                //                print(pm.country)
//                //                print(pm.locality)
//                //                print(pm.subLocality)
//                //                print(pm.thoroughfare ?? "")
//                //                print(pm.postalCode)
//                //                print(pm.subThoroughfare)
//                //                var addressString : String = ""
//                //                if pm.subLocality != nil {
//                //                    addressString = addressString + pm.subLocality! + ", "
//                //                }
//                //                if pm.thoroughfare != nil {
//                //                   addressString = addressString + pm.thoroughfare! + ", "
//                //                }
//                //                if pm.locality != nil {
//                //                    addressString = addressString + pm.locality! + ", "
//                //                }
//                //                if pm.country != nil {
//                //                    addressString = addressString + pm.country! + ", "
//                //                }
//                //                if pm.postalCode != nil {
//                //                    addressString = addressString + pm.postalCode! + " "
//                //                }
//                //                print(addressString)
//            }
//    })
//
//}
func global_timeAgoSinceDate(time:TimeInterval, numericDates:Bool = true) -> String {
    let date:NSDate = NSDate(timeIntervalSince1970: time)
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = NSDate()
    let earliest = now.earlierDate(date as Date)
    let latest = (earliest == now as Date) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
}

