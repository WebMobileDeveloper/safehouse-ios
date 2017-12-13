//
//  zoneDetailViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import UIKit
import MapKit
import CoreData
import CoreLocation
import Foundation

class zoneDetailViewController: UIViewController, MKMapViewDelegate {
    var zone:zoneStruct = zoneStruct()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainMapView: MKMapView!

    
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func onEditButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "editZoneViewController") as? editZoneViewController {
            viewController.zone = zone
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func onDeleteButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "confirmRemoveZoneViewController") as? confirmRemoveZoneViewController {
            viewController.zoneId = zone.id
            self.present(viewController, animated:true, completion:nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        mainMapView.showsUserLocation = true
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        titleLabel.text = zone.name != "" ? zone.name : "Unnamed Zone"
        let center = getCenter()
        let region = MKCoordinateRegion(center: center, span : span)
        mainMapView.setRegion(region, animated: true)
        
        updateZones()
        updateAnnotations()
    }
    func getCenter()->CLLocationCoordinate2D{
        var maxLat:Double = -200;
        var maxLong:Double = -200;
        var minLat:Double = 1000;
        var minLong:Double = 1000;
        for val in zone.polygon{
            if val.latitude < minLat {
                minLat = val.latitude;
            }
            if val.longitude < minLong {
                minLong = val.longitude;
            }
            if val.latitude > maxLat {
                maxLat = val.latitude;
            }
            if val.longitude > maxLong {
                maxLong = val.longitude;
            }
        }
        
        //Center point
        let center = CLLocationCoordinate2DMake((maxLat + minLat) * 0.5, (maxLong + minLong) * 0.5);
        return center
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
            annotationView.image = resizeImage(image: #imageLiteral(resourceName: "addZoneAnnotation"), newWidth: 20.0)
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
        var zoneAnnotations:[zoneAnnotation] = []
        var i=0
        for point in zone.polygon{
            let annotation:zoneAnnotation = zoneAnnotation()
            annotation.coordinate = point
            annotation.zoneIndex = i
            i = i + 1
            zoneAnnotations.append(annotation)
        }
        mainMapView.addAnnotations(zoneAnnotations)
    }
    
    func updateZones(){
        mainMapView.removeOverlays(mainMapView.overlays)
        
        let polygon:zonePolygon = zonePolygon(coordinates: zone.polygon, count: zone.polygon.count)
        if zone.safe == 0{
            polygon.setType(type: .unSafeZone)
        }
        mainMapView.add(polygon)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func onDeleteConfirm() {
//        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
//        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
//    }
    
}
