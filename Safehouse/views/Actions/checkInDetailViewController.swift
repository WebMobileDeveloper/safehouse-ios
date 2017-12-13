//
//  checkInDetailViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/29/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import UIKit
import MapKit
import CoreData
import CoreLocation
import Foundation



class checkInDetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var event:eventStruct = eventStruct()
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var checkInImage: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblMessageBig: UILabel!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var eventDegreeImageView: UIImageView!
    @IBOutlet weak var fullImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        titleLabel.text = "Check-In"
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
        if event.photo_text != ""{
            lblMessage.text = event.photo_text
            lblMessageBig.text = event.photo_text
        }else{
            lblMessage.isHidden = true
            //lblMessageBig.isHidden = true
        }
        eventDegreeImageView.backgroundColor = event.degreeColor()
        let photo_url = user.checkinRequests[0].photo_url
        if photo_url != "" {
            let url = URL(string:photo_url)
            let data = try? Data(contentsOf: url!)
            if data != nil{
                fullImage.image = UIImage(data: data!)
                checkInImage.image = UIImage(data: data!)
            }
        }
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        let region = MKCoordinateRegion(center: event.location, span : span)
        mainMapView.setRegion(region, animated: true)
        updateZones()
        addAnnotation()
        
        /* MARK: -  make image to Tapable*/
        checkInImage.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
        //Add the recognizer to your view.
        checkInImage.addGestureRecognizer(tapRecognizer)
        
        
        fullImage.isUserInteractionEnabled = true
        let tapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage(_:)))
        //Add the recognizer to your view.
        fullImage.addGestureRecognizer(tapRecognizer1)
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
    func updateZones(){
         for key in user.zones {
            let polygon:zonePolygon = zonePolygon(coordinates: key.polygon, count: key.polygon.count)
            if key.safe == 0{
                polygon.setType(type: .unSafeZone)
            }
            mainMapView.add(polygon)
        }
    }
//    func imageTapped(_ sender: UITapGestureRecognizer) {
//        let imageView = sender.view as! UIImageView
//        var image:UIImage = imageView.image!
//        var width:CGFloat = 0
//        var height:CGFloat = 0
//        if (UIScreen.main.bounds.width / UIScreen.main.bounds.height) > (image.size.width / image.size.height){
//            width = image.size.width
//            height = image.size.height * image.size.width / UIScreen.main.bounds.width
//        }else{
//            width = image.size.width * image.size.height / UIScreen.main.bounds.height
//            height = image.size.height
//        }
//        image = cropToRect(image: image, width: width, height: height)!
//        let newImageView = UIImageView(image: image)
//
//        newImageView.frame = UIScreen.main.bounds
//
//
//        newImageView.backgroundColor = .white
//        newImageView.contentMode = .scaleAspectFit
//        newImageView.isUserInteractionEnabled = true
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
//        newImageView.addGestureRecognizer(tap)
//
//        self.view.addSubview(newImageView)
//        self.navigationController?.isNavigationBarHidden = true
//        self.tabBarController?.tabBar.isHidden = true
//
//        lblMessageBig.isHidden = false
//        newImageView.bringSubview(toFront: lblMessageBig)
//        lblMessageBig.layer.zPosition = CGFloat(CGFloat.greatestFiniteMagnitude)
//    }
    func imageTapped(_ sender: UITapGestureRecognizer) {
        fullImage.isHidden = false
        if lblMessage.text != ""{
            lblMessageBig.isHidden = false
        }
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        lblMessageBig.isHidden = true
        fullImage.isHidden = true
    }
    @IBAction func onBackButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
