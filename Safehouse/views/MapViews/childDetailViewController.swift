//
//  childDetailViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/26/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import UIKit
import MapKit
import CoreData
import CoreLocation
import Foundation



class childDetailViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addZoneButton: UIButton!
    @IBOutlet weak var childDetailTableView: UITableView!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var BtnConfirmCheckIn: UIButton!
  
    
    var locManager:CLLocationManager!
    var currLocation: CLLocation = CLLocation()
    var lastLocation:CLLocation = CLLocation()
    
    
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    var isStatusBarHidden = false   
    var events:[eventStruct] = []
    
    @IBAction func onBackBtnClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func onAddZoneButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "addZoneViewController") as? addZoneViewController {
            if let navigator = self.navigationController {
                //viewController.childName = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
   
    @IBAction func viewTrailBtnClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "trailViewController") as? trailViewController {
            if let navigator = self.navigationController {
                //viewController.childName = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func getDirectionsBtnClick(_ sender: Any) {
    }
    @IBAction func RequestCheckBtnClick(_ sender: Any) {
        self.startActivityIndicator(style: .gray)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.checkInSend(child_id: user.child_id) { result in
            self.stopActivityIndicator()
            if result {
                self.setNeedsStatusBarAppearanceUpdate()
                self.BtnConfirmCheckIn.fadeIn(duration: 0.5, delay: 0, completion: { (finished) in
                    self.BtnConfirmCheckIn.fadeOut(duration: 1, delay: 3, completion: { (finished) in
                        self.isStatusBarHidden = false
                        self.setNeedsStatusBarAppearanceUpdate()
                    })
                })
            }else{
                showAlert(target: self, message: "Error was occured during send check in request.\n please check your network status.")
            }
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        nameLabel.text = user.child.name
        
      
        
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType = MKMapType.standard
        childDetailTableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "tableback"))
        
        user.getChildInfo {
            self.updateZones()
            self.updateAnnotations()
            self.childDetailTableView.reloadData()
            let region = MKCoordinateRegion(center: user.child.current_location , span : self.span)
            self.mainMapView.setRegion(region, animated: true)
        }
        user.getChildEvents { (result) in
            self.events.removeAll()
            for event in result {
                var newEvent:eventStruct = eventStruct()
                newEvent.level = event["level"] as? Int ?? 1
                newEvent.time = event["time"] as? TimeInterval ?? 0
                let loc = event["location"] as? [String: Double] ?? ["lat":0,"long":0]
                let lat = loc["lat"] ?? 0
                let long = loc["long"] ?? 0
                newEvent.location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let eventStr:String = event["type"] as? String ?? ""
                
                switch eventStr {
                case "battery_low":
                    break
                    //battery_percent: 0.5
                case "app_installed":
                    break
                case "app_uninstalled":      /* app uninstalled */
                    break
                case "device_off":           /* device off */
                    break
                case "speeding":             /* speeding */
                    newEvent.type = eventType.speedOver
                    newEvent.speed = event["speed"] as? Int ?? 0                /* km per hr */
                    newEvent.speed_limit = event["speed_limit"] as? Int ?? 0    /* km per hr */
                    self.events.insert(newEvent, at: 0)
                case "enter_safe_zone":         /* enter safe zone */
                    newEvent.type = eventType.enterSafeZone
                    let zone_id = event["zone_id"] as? String ?? ""
                    for zone in user.zones{
                        if zone.id == zone_id {
                            newEvent.zoneName = zone.name
                        }
                    }
                    self.events.insert(newEvent, at: 0)
                case "leave_safe_zone":         /* leave safe zone */
                    newEvent.type = eventType.leaveSafeZone
                    let zone_id = event["zone_id"] as? String ?? ""
                    for zone in user.zones{
                        if zone.id == zone_id {
                            newEvent.zoneName = zone.name
                        }
                    }
                    self.events.insert(newEvent, at: 0)
                case "enter_unsafe_zone":       /* enter unsafe zone */
                    newEvent.type = eventType.enterUnsafeZone
                    let zone_id = event["zone_id"] as? String ?? ""
                    for zone in user.zones {
                        if zone.id == zone_id {
                            newEvent.zoneName = zone.name
                        }
                    }
                    self.events.insert(newEvent, at: 0)
                case "leave_unsafe_zone":       /* leave unsafe zone */
                    newEvent.type = eventType.leaveUnsafeZone
                    let zone_id = event["zone_id"] as? String ?? ""
                    for zone in user.zones {
                        if zone.id == zone_id {
                            newEvent.zoneName = zone.name
                        }
                    }
                    self.events.insert(newEvent, at: 0)
                case "bad_msg":                 /* bad msg */
                    newEvent.type = eventType.badTextMessage
                    newEvent.key_phrase = event["key_phrase"] as? String ?? ""
                    newEvent.msg = event["msg"] as? String ?? ""
                    newEvent.sent = event["sent"] as? Int ?? 1
                    newEvent.sender_name =  event["sender_name"] as? String ?? "" /* only available when sent=0 */
                    self.events.insert(newEvent, at: 0)
                case "checkin":                 /* checkin */
                    break
//                    photo_url: "http://url/to/photo"
//                    photo_text: "text on photo"
//                    checkin_id: "checkin id"
                case "emergency_request":       /* emergency request */
                    newEvent.type = eventType.emergencyRequest
                    newEvent.audio_url = event["audio_url"] as? String ?? ""
                    newEvent.emergency_request_id = event["emergency_request_id"] as? String ?? ""
                    self.events.insert(newEvent, at: 0)
                default:
                    break
                }
                self.childDetailTableView.reloadData()
            }
        }
        
    }
    
    

    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currLocation = manager.location!
//        let distanceInMeters = currLocation.distance(from: lastLocation) // result is in meters
//
//
//        if distanceInMeters > 100 {
//            lastLocation = currLocation
//            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:currLocation.coordinate.latitude + 0.008,longitude: currLocation.coordinate.longitude), span : span)
//            mainMapView.setRegion(region, animated: true)
//
//
//            let overlays = mainMapView.overlays
//            mainMapView.removeOverlays(overlays)
//
//
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Errors: " + error.localizedDescription)
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        let fA = annotation as! familyAnnotation
        annotationView?.image = fA.image
        return annotationView
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 1
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 1
            return renderer
        }else if overlay is MKPolygon {
            //mainMapView.remove(overlay)
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            let zone = overlay as! zonePolygon
            if zone.type == .safeZone{
                renderer.fillColor = UIColor.init(red: 84/255, green: 218/255, blue: 154/255, alpha: 0.2)
                renderer.strokeColor = UIColor.init(red: 84/255, green: 218/255, blue: 154/255, alpha: 1)
            }else{
                renderer.fillColor = UIColor.init(red: 213/255, green: 101/255, blue: 116/255, alpha: 0.2)
                renderer.strokeColor = UIColor.init(red: 213/255, green: 101/255, blue: 116/255, alpha: 1)
            }
            
            renderer.lineWidth = 1
            return renderer
        }
        
        return MKOverlayRenderer()
    }

    func updateAnnotations() {
        let annotation:familyAnnotation = familyAnnotation()
        mainMapView.removeAnnotations(mainMapView.annotations)
        annotation.coordinate = user.child.current_location
        if user.child.photo_url != ""{
            let url = URL(string: user.child.photo_url)
            let data = try? Data(contentsOf: url!)
            annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: UIImage(data: data!)!)
        }else{
            annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: #imageLiteral(resourceName: "editProfilePhotoGreyIcon"))
        }
        mainMapView.addAnnotation(annotation)
    }
    
    func updateZones(){
        mainMapView.removeOverlays(mainMapView.overlays)
        for key in user.zones {
            let polygon:zonePolygon = zonePolygon(coordinates: key.polygon, count: key.polygon.count)
            if key.safe == 0{
                polygon.setType(type: .unSafeZone)
            }
            mainMapView.add(polygon)
        }
    }
    
    
    
    //MARK: - UITableViewDataSource functions
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return events.count
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 25
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "childDetailTableViewCell") as! childDetailTableViewCell
            let batteryIcons: [UIImage] = [#imageLiteral(resourceName: "BatteryLowIcon"), #imageLiteral(resourceName: "BatteryMed1Icon"), #imageLiteral(resourceName: "BatteryMed2Icon"), #imageLiteral(resourceName: "BatteryMed2Icon"), #imageLiteral(resourceName: "BatteryMed3Icon"), #imageLiteral(resourceName: "BatteryFullIcon")]
            //display street
            reverseGeocoding(lat: user.child.current_location.latitude, long: user.child.current_location.longitude , completionHandler: { (pm) in
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
                cell.positionLabel.text = addressString
            })
            //display photo
            if user.child.photo_url != ""{
                let url = URL(string:user.child.photo_url)
                let data = try? Data(contentsOf: url!)
                if data != nil{
                    cell.profileImage.image = UIImage(data: data!)
                }else{
                    cell.profileImage.image = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
                }                
            }else{
                cell.profileImage.image = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
            }
            cell.batteryImage.image = batteryIcons[Int(floor(Double(user.child.current_battery_percent) / 20.0))]
            cell.batteryPercent.text = "\(user.child.current_battery_percent)%"
            if user.child.current_battery_percent < 20 {
                cell.batteryPercent.textColor = UIColor.red
            }
            cell.onOffStateLabel.text = "Device \(user.child.current_device_on_off)"           //cell.selectionStyle = .none
          
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "childHistoryTableViewCell") as! childHistoryTableViewCell
            cell.configCell(initData: events[row])
            cell.eventDetailBtn.tag = indexPath.row
            cell.eventDetailBtn.addTarget(self, action: #selector(selectDetail(sender:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
            case 0:
                return nil
            case 1:
                let header = tableView.dequeueReusableCell(withIdentifier: "childHistorySectionHeaderCell") as! childHistorySectionHeaderCell
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE MMM dd"
                header.headerTitleLabel.text = formatter.string(from: date)
                return header
            default:
                return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            switch events[indexPath.row].type {
            case .badTextMessage:
                if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "badMessageViewController") as? badMessageViewController {
                    if let navigator = self.navigationController {
                        viewController.event = events[indexPath.row]
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case .speedOver:
                if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "speedingViewController") as? speedingViewController {
                    if let navigator = self.navigationController {
                        viewController.event = events[indexPath.row]
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case .enterUnsafeZone,.enterSafeZone,.leaveSafeZone,.leaveUnsafeZone:
                if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "unSafeZoneViewController") as? unSafeZoneViewController {
                    if let navigator = self.navigationController {
                        viewController.event = events[indexPath.row]
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case .emergencyRequest:
                if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "PanicButtonPressedViewController") as? PanicButtonPressedViewController {
                    if let navigator = self.navigationController {
                        viewController.event = events[indexPath.row]
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    func selectDetail(sender: UIButton){
        let buttonTag = sender.tag
        switch events[buttonTag].type {
        case .badTextMessage:
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "badMessageViewController") as? badMessageViewController {
                if let navigator = self.navigationController {
                    viewController.event = events[buttonTag]
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .speedOver:
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "speedingViewController") as? speedingViewController {
                if let navigator = self.navigationController {
                    viewController.event = events[buttonTag]
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .enterUnsafeZone,.enterSafeZone,.leaveSafeZone,.leaveUnsafeZone:
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "unSafeZoneViewController") as? unSafeZoneViewController {
                if let navigator = self.navigationController {
                    viewController.event = events[buttonTag]
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .emergencyRequest:
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "PanicButtonPressedViewController") as? PanicButtonPressedViewController {
                if let navigator = self.navigationController {
                    viewController.event = events[buttonTag]
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    
    //MARK:- Status bar hidden state change functions
   
    override var prefersStatusBarHidden : Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        // .None:
        // .Slide:
        // .Fade
        return UIStatusBarAnimation.slide
    }
    
    //    @IBAction func CheckInConfirmBtnClick(_ sender: Any) {
    //        let indexPath:NSIndexPath = NSIndexPath(row: 0, section: 0)
    //        let cell = self.childDetailTableView.cellForRow(at: indexPath as IndexPath) as? childDetailTableViewCell
    //        if let cell1 = cell {
    //            cell1.lblJustNow.isHidden = true
    //        }
    //        self.BtnConfirmCheckIn.isHidden = true
    //        /* MARK: - SHOW STATUS BAR
    //         */
    //        isStatusBarHidden = false
    //        self.setNeedsStatusBarAppearanceUpdate()
    //
    //        /* MARK: - SHOW MODAL
    //        */
    //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //        appDelegate.showCheckInModal()
    //
    //    }

   

}
