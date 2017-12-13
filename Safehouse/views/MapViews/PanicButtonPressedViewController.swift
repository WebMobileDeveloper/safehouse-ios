//
//  PanicButtonPressedViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/28/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import UIKit
import MapKit
import CoreData
import CoreLocation
import Foundation
import AVFoundation


class PanicButtonPressedViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AVAudioPlayerDelegate {
    
    
    
    var event:eventStruct = eventStruct()
    var soundPlayer:AVAudioPlayer!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var btnCallChild: UIButton!
    @IBOutlet weak var hearButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callChildButton: UIButton!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var eventDegreeImageView: UIImageView!
    
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        let region = MKCoordinateRegion(center: event.location, span : span)
        mainMapView.setRegion(region, animated: true)
        
        titleLabel.text = event.eventTitle()
        btnCallChild.setTitle("CAll \(user.child.name)", for: .normal)
        eventDegreeImageView.backgroundColor = event.degreeColor()
        timeLabel.text = event.DateTime()
        reverseGeocoding(lat: event.location.latitude, long: event.location.longitude , completionHandler: { (pm) in
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
            self.locationLabel.text = addressString
        })
        
        addAnnotation()
        addZones()
    }
    
    override func viewDidLayoutSubviews() {
        self.hearButton.layer.cornerRadius = self.hearButton.frame.height / 2
        self.callButton.layer.cornerRadius = self.callButton.frame.height / 2
        self.callChildButton.layer.cornerRadius = self.callChildButton.frame.height / 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    func addAnnotation() {
        let annotation:familyAnnotation = familyAnnotation()
        annotation.coordinate = event.location
        if user.child.photo_url != "" {
            let url = URL(string: user.child.photo_url)
            let data = try? Data(contentsOf: url!)
            annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: UIImage(data: data!)!)
        }else{
            annotation.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: #imageLiteral(resourceName: "editProfilePhotoGreyIcon"))
        }
        mainMapView.addAnnotation(annotation)
    }
    func addZones(){
        for key in user.zones {
            let polygon:zonePolygon = zonePolygon(coordinates: key.polygon, count: key.polygon.count)
            if key.safe == 0{
                polygon.setType(type: .unSafeZone)
            }
            mainMapView.add(polygon)
        }
        
    }
    func preparePlayer() {
        do  {
            try soundPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: event.audio_url))
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 5.0
        } catch {
            print("AVAudioPlayer error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    @IBAction func btnHearAudioClicked(_ sender: Any) {
        preparePlayer()
        soundPlayer.play()
    }
    
    @IBAction func btnCall911Clicked(_ sender: Any) {
        if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnCallChildClicked(_ sender: Any) {
        if user.child.phone != ""{
            if let url = URL(string: "tel://" + user.child.phone ), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }else{
                showAlert(target: self, message: "\(user.child.name)'s phone number can't find.")
            }
        }else{
            showAlert(target: self, message: "\(user.child.name)'s phone number can't find.")
        }
    }
    
    
    
}
