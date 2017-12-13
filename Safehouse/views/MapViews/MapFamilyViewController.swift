//
//  MapFamilyViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/22/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import MapKit
import CoreData
//import CoreLocation
import Foundation
class MapFamilyViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var addZoneButton: UIButton!
    @IBOutlet weak var familyTableView: UITableView!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var addMemberButton: UIButton!
    @IBOutlet weak var titleLable: UILabel!
    
    
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    var locManager:CLLocationManager!
    var currLocation: CLLocation = CLLocation()
    var lastLocation:CLLocation = CLLocation()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLable.text = user.name + "  Family"
        
        
//        //MARK: - Setup Location Manager
//        locManager = CLLocationManager()
//        locManager.delegate = self
//        locManager.desiredAccuracy = 100   //kCLLocationAccuracyBest  //default 5m
//        locManager.requestAlwaysAuthorization()
//        locManager.startUpdatingLocation()
        
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        //mainMapView.showsUserLocation = true
        
        assignbackground()
        
        
        user.getZones {
            self.updateZones()
        }
        user.getFamilyMembers {
            self.familyTableView.reloadData()
            self.updateAnnotations()
            
            let region = MKCoordinateRegion(center: user.current_location , span : self.span)
            self.mainMapView.setRegion(region, animated: true)
        }
        
        user.getEmergencyRequests {
            self.appDelegate.getLocationHistory(completionHandler: {
                if !user.emergencyRequests.isEmpty{
                    self.appDelegate.showEmergencyInModal()
                }else{
                    user.getCheckInRequests {
                        if !user.checkinRequests.isEmpty{
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.showCheckInModal()
                        }
                    }
                }
            })
        }
    }
    override func viewDidLayoutSubviews() {
        addMemberButton.layer.cornerRadius = addMemberButton.frame.height / 2
    }
    func assignbackground(){
        let background = UIImage(named: "tableback")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        familyTableView.backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Errors: " + error.localizedDescription)
//    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "My Pic"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView: MKAnnotationView
        if let dequeuedView  = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView .annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
        }
        let fA = annotation as! familyAnnotation
        annotationView.image = fA.image
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let faAnno = view.annotation as! familyAnnotation
        switch faAnno.type {
        case .child:
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "childDetailViewController") as? childDetailViewController {
                if let navigator = self.navigationController {
                    user.child_id = faAnno.uid
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .parent:
            return
        }
    }
    
    func updateAnnotations() {
        var annotations:[familyAnnotation]=[]
        mainMapView.removeAnnotations(mainMapView.annotations)
        for member in user.familyMembers{
            let annotation:familyAnnotation = familyAnnotation()
            annotation.coordinate = member.current_location
            if member.type == "parent" {
                annotation.type = .parent(name: member.name)
            }else{
                annotation.type = .child(name: member.name)
            }
            if member.photo_url != ""{
                let url = URL(string: member.photo_url)
                let data = try? Data(contentsOf: url!)
                if data != nil{
                    annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: UIImage(data: data!)!)
                }else{
                    annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: #imageLiteral(resourceName: "editProfilePhotoGreyIcon"))
                }
            }else{
                annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: #imageLiteral(resourceName: "editProfilePhotoGreyIcon"))
            }
            annotation.uid = member.uid
            annotation.title = "\(member.name)'s Location"
            annotation.subtitle = member.name
            annotations.append(annotation)
        }
        mainMapView.addAnnotations(annotations)
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
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return user.familyMembers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "familyMemberTableViewCell") as! familyMemberTableViewCell
        let batteryIcons: [UIImage] = [#imageLiteral(resourceName: "BatteryLowIcon"), #imageLiteral(resourceName: "BatteryMed1Icon"), #imageLiteral(resourceName: "BatteryMed2Icon"), #imageLiteral(resourceName: "BatteryMed2Icon"), #imageLiteral(resourceName: "BatteryMed3Icon"), #imageLiteral(resourceName: "BatteryFullIcon")]
        if user.familyMembers[indexPath.row].photo_url != ""{
            let url = URL(string:user.familyMembers[indexPath.row].photo_url)
            let data = try? Data(contentsOf: url!)
            if (data != nil) {
                cell.profileImage.image = UIImage(data: data!)
            }else{
                cell.profileImage.image = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
            }
        }else{
            cell.profileImage.image = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
        }
        cell.profileName.text =  user.familyMembers[indexPath.row].name
        cell.batteryImage.image = batteryIcons[Int(floor(Double(user.familyMembers[indexPath.row].current_battery_percent) / 20.0))]
        cell.batteryPercent.text = "\(user.familyMembers[indexPath.row].current_battery_percent)%"
        if user.familyMembers[indexPath.row].current_battery_percent < 20 {
            cell.batteryPercent.textColor = UIColor.red
        }
        if user.familyMembers[indexPath.row].message_count > 0 {
            cell.messageCount.text = "\(user.familyMembers[indexPath.row].message_count)"
        }else{
            cell.messageCount.isHidden = true
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if user.familyMembers[indexPath.row].type == "child" {
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "childDetailViewController") as? childDetailViewController {
                if let navigator = self.navigationController {
                    user.child_id = user.familyMembers[indexPath.row].uid
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 75
        }else{
            return 60
        }
    }
    
    
    @IBAction func onSettingsButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "settingsTableViewController") as? settingsTableViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onAddZoneButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "addZoneViewController") as? addZoneViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func onAddMemberButtonClick(_ sender: Any) {
    }
    
   
 
}
