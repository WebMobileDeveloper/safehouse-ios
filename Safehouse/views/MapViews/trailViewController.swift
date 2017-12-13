//
//  trailViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/27/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import MapKit
import CoreData
import CoreLocation
import Foundation

class trailViewController: UIViewController, MKMapViewDelegate{
    
    
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var dateStr = ""
    var date = Date()
    
    
    
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    let arrowLength: Float = 80
    let arrowAngle = (50.0).degreesToRadians;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        mainMapView.showsUserLocation = false
        updateDate(add: 0)
        assignbackground()
      
        
        
    }
    func updateDate(add:Int){
        date = date + add.days
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        dateStr = formatter.string(from: date)
        
        formatter.dateFormat = "EEEE MMMM dd"
        dateLabel.text = formatter.string(from: date)
        
        let region = MKCoordinateRegion(center: user.child.current_location, span : span)
        mainMapView.setRegion(region, animated: true)
        mainMapView.removeOverlays(mainMapView.overlays)
        updateZones()
        updateTrail()
        for a in user.locationHistories{
            print(a)
        }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let region = MKCoordinateRegion(center: curr.coordinate, span : self.span)
                self.mainMapView.setRegion(region, animated: true)
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
            annotationView.image = resizeImage(image: #imageLiteral(resourceName: "trailAnnotation"), newWidth: 10.0)
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
                renderer.lineWidth = 5
            }else{
                renderer.strokeColor = UIColor.init(red: 1, green: 0.2, blue: 0.2, alpha: 0.8)
                renderer.lineWidth = 3
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
    
    //MARK: - UITableViewDataSource functions
    @IBAction func onBackBtnClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func beforeDayBtnClick(_ sender: Any) {
        updateDate(add: -1)
    }
    @IBAction func nextDayBtnClick(_ sender: Any) {
        updateDate(add: 1)
    }
    
}
