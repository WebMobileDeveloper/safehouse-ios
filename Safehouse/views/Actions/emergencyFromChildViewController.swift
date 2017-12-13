//
//  emergencyFromChildViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/29/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import MapKit
import CoreData
import CoreLocation
import Foundation
class emergencyFromChildViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTimeAndStreet: UILabel!
    @IBOutlet weak var btnHearAudio: UIButton!
    @IBOutlet weak var btnAlert911: UIButton!
    @IBOutlet weak var btnCallChild: UIButton!
   
    let span = MKCoordinateSpan(latitudeDelta: 0.005,longitudeDelta: 0.005)
    let arrowLength: Float = 30
    let arrowAngle = (50.0).degreesToRadians;
    var childAnnotations:[familyAnnotation]=[]

    var dateStr = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = "Emergency Request From \(user.emergencyRequests[0].child_name)"
        btnCallChild.setTitle("Call \(user.emergencyRequests[0].child_name)", for: .normal)
        
        let date = Date(timeIntervalSince1970: user.emergencyRequests[0].time)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        dateStr = formatter.string(from: date)
        reverseGeocoding(lat: user.emergencyRequests[0].location.latitude, long: user.emergencyRequests[0].location.longitude , completionHandler: { (pm) in
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
            self.lblTimeAndStreet.text = "\(global_timeAgoSinceDate(time: user.emergencyRequests[0].time, numericDates: true)) \(addressString)"
        })
        
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        mainMapView.showsUserLocation = false
        let region = MKCoordinateRegion(center: user.emergencyRequests[0].location, span : span)
        mainMapView.setRegion(region, animated: true)
        
        updateZones()
        updateTrail()
        updateAnnotations()
        
    }
    override func viewDidLayoutSubviews() {
        self.btnHearAudio.layer.cornerRadius = self.btnHearAudio.frame.height / 2
        self.btnAlert911.layer.cornerRadius = self.btnAlert911.frame.height / 2
        self.btnCallChild.layer.cornerRadius = self.btnCallChild.frame.height / 2
    }
    
    

    func updateAnnotations() {
        var annotations:[MKPointAnnotation]=[]
        for point in user.locationHistories[dateStr]!{
            let annotation = MKPointAnnotation.init()
            annotation.coordinate = CLLocationCoordinate2D(latitude: point.location["lat"]!, longitude: point.location["long"]!)
            annotation.title = global_timeAgoSinceDate(time: point.start_timestamp, numericDates: false)
            reverseGeocoding(lat: point.location["lat"]!, long: point.location["long"]! , completionHandler: { (pm) in
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
                annotation.subtitle = addressString
            })
            
            annotations.append(annotation)
        }
        mainMapView.addAnnotations(annotations)
        
        let newChildAna: familyAnnotation = familyAnnotation()
        newChildAna.coordinate.latitude = user.emergencyRequests[0].location.latitude
        newChildAna.coordinate.longitude = user.emergencyRequests[0].location.longitude
        let url = URL(string: user.emergencyRequests[0].photo_url)
        let data = try? Data(contentsOf: url!)
        if data != nil{
            newChildAna.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: UIImage(data: data!)!)
        }else{
            newChildAna.image = UIImage.onePersonAnnotationImage(frameImage: #imageLiteral(resourceName: "PinSafe"), profileImage: #imageLiteral(resourceName: "editProfilePhotoGreyIcon"))
        }
        
        newChildAna.type =  .child(name: user.emergencyRequests[0].child_name)
        newChildAna.title = "\(user.emergencyRequests[0].child_name)'s Location"
        newChildAna.subtitle = user.emergencyRequests[0].child_name
        childAnnotations.append(newChildAna)
        mainMapView.addAnnotations(childAnnotations)
    }
    func updateZones(){
        for key in user.zones {
            var locations = key.polygon.map { $0 }
            let polygon:zonePolygon = zonePolygon(coordinates: &locations, count: locations.count)
            if key.safe == 1 {
                polygon.setType(type: .safeZone)
            }else{
                polygon.setType(type: .unSafeZone)
            }
            mainMapView.add(polygon)
        }
    }
    
    func updateTrail() {
        var start:CLLocation!
        var locations:[CLLocationCoordinate2D] = []
        var directions:[[CLLocation]]=[]
        _ = user.locationHistories[dateStr]?.map({
            
            let curr = CLLocation(latitude: $0.location["lat"]!, longitude: $0.location["long"]!)
            locations.append(curr.coordinate)
            guard let start1 = start else {
                start = curr
                return
            }
            let bearing = atan2(curr.coordinate.latitude - start1.coordinate.latitude, curr.coordinate.longitude - start1.coordinate.longitude) - Double.pi;
            //Get other two corners of triangle
            let pt1:CLLocation = PointAtBearingFromPoint(center: curr, theta: Float(CGFloat(bearing) + arrowAngle / 2), R: arrowLength)
            let pt2:CLLocation = PointAtBearingFromPoint(center: curr, theta: Float(CGFloat(bearing) - arrowAngle / 2), R: arrowLength)
            
            directions.append([pt1, curr, pt2])
            start = curr
        })

        let polyline:CustomPolyline = CustomPolyline(coordinates: &locations, count: locations.count)
        mainMapView.add(polyline)
        
        _ = directions.map{
            var locations = $0.map{$0.coordinate}
            let polyline: CustomPolyline = CustomPolyline(coordinates: &locations, count: locations.count)
            polyline.setType(type: .arrow)
            mainMapView.add(polyline)
        }
        
    }
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
            if annotation is familyAnnotation{
                let fA = annotation as! familyAnnotation
                annotationView.image = fA.image
            } else {
                annotationView.image = resizeImage(image: #imageLiteral(resourceName: "trailAnnotation"), newWidth: 5.0)
            }
        }
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
            let line = overlay as! CustomPolyline
            
            if line.type == .general{
                renderer.strokeColor = UIColor.init(red: 0.6, green: 0.8, blue: 0.9, alpha: 0.8)
                renderer.lineWidth = 2
            }else{
                renderer.strokeColor = UIColor.init(red: 1, green: 0.2, blue: 0.2, alpha: 0.8)
                renderer.lineWidth = 2
            }
            return renderer
        } else if overlay is MKPolygon {
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
    @IBAction func btnCloseClick(_ sender: Any) {
        user.seenEmergencyRequestCheck()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnHearAudioClick(_ sender: Any) {
        let mVC = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "playingViewController") as! playingViewController
        mVC.modalPresentationStyle = .overCurrentContext
        self.present(mVC, animated: true, completion: nil)
    }
    @IBAction func btnAlert911Click(_ sender: Any) {
        let mVC = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "Alert911ViewController") as! Alert911ViewController
        mVC.modalPresentationStyle = .overCurrentContext
        self.present(mVC, animated: true, completion: nil)
    }
    
    @IBAction func btnCallChildClick(_ sender: Any) {
        if user.emergencyRequests[0].phone != ""{
            if let url = URL(string: "tel://\(user.emergencyRequests[0].phone)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }else{
            showAlert(target: self, message: "We can't find your child phone number.")
        }
    }
}
