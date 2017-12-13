//
//  unSafeZoneViewController.swift
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



class unSafeZoneViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eventDegreeImageView: UIImageView!
    @IBOutlet weak var mainMapView: MKMapView!
    
    var event:eventStruct = eventStruct()
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        let region = MKCoordinateRegion(center: event.location, span : span)
        mainMapView.setRegion(region, animated: true)
        
        titleLabel.text = event.eventTitle()
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
        
        assignbackground()
        addAnnotation()
        addZones()
        
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
    func addZones(){
        for key in user.zones {
            let polygon:zonePolygon = zonePolygon(coordinates: key.polygon, count: key.polygon.count)
            if key.safe == 0{
                polygon.setType(type: .unSafeZone)
            }
            mainMapView.add(polygon)
        }
        
    }
    
}
