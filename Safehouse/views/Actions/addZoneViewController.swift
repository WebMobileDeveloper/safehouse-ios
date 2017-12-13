//
//  addZoneViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/30/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
import Foundation

class addZoneViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate ,CustomButtonDelegate{

    @IBOutlet weak var outerSegmentView: UIView!
    @IBOutlet weak var zoneTypeSegment: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var zoneAddressField: UITextField!
    @IBOutlet weak var zoneNameField: UITextField!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var mainMapView: MKMapView!
    var locManager:CLLocationManager!
    var currLocation: CLLocation = CLLocation()
    var lastLocation:CLLocation = CLLocation()
    
    var zones:[CLLocationCoordinate2D] = []
    var zoneAnnotations:[zoneAnnotation] = []
    let span = MKCoordinateSpan(latitudeDelta: 0.02,longitudeDelta: 0.02)
    var continueInputAccessoryView : CustomAccessoryView?
    
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func typeChange(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:  // safe zone
            outerSegmentView.borderColor = UIColor(red: 56/255, green: 215/255, blue: 142/255, alpha: 1)
            sender.tintColor = UIColor(red: 56/255, green: 215/255, blue: 142/255, alpha: 1)
        case 1:  // unsafe zone
            outerSegmentView.borderColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
            sender.tintColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
        default:
            return
            
        }
        updateZones()
    }
    
    @IBAction func onAddButtonClick(_ sender: Any) {
        onClickNext()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoneTypeSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)], for: UIControlState())
        zoneTypeSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)], for:.selected)
        
        //MARK: - Setup Location Manager
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = 100   //kCLLocationAccuracyBest  //default 5m
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        mainMapView.showsUserLocation = true
        
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        
        self.continueInputAccessoryView?.delegate = self as CustomButtonDelegate
        continueInputAccessoryView?.BtnAction.setTitle("ADD ZONE", for: .normal)
        continueInputAccessoryView?.BtnAction.layer.backgroundColor = UIColor(red: 72/255, green: 192/255, blue: 1, alpha: 1).cgColor
        continueInputAccessoryView?.BtnAction.setTitleColor(UIColor.white, for: .normal)
        self.zoneAddressField.inputAccessoryView = continueInputAccessoryView
        self.zoneNameField.inputAccessoryView = continueInputAccessoryView
        
        NotificationCenter.default.addObserver(self, selector: #selector(addZoneViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addZoneViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currLocation = manager.location!
        let distanceInMeters = currLocation.distance(from: lastLocation) // result is in meters
        
        
        if distanceInMeters > 100 {
            lastLocation = currLocation
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:currLocation.coordinate.latitude + 0.008,longitude: currLocation.coordinate.longitude), span : span)
            mainMapView.setRegion(region, animated: true)
            //print("locations = \(currLocation.coordinate.latitude) \(currLocation.coordinate.longitude)")
            
            
            let overlays = mainMapView.overlays
            mainMapView.removeOverlays(overlays)
            
            if zones.isEmpty {
                zones = [CLLocationCoordinate2DMake(currLocation.coordinate.latitude + 0.015, currLocation.coordinate.longitude - 0.004),
                         CLLocationCoordinate2DMake(currLocation.coordinate.latitude + 0.012, currLocation.coordinate.longitude - 0.002),
                         CLLocationCoordinate2DMake(currLocation.coordinate.latitude + 0.007, currLocation.coordinate.longitude - 0.005),
                         CLLocationCoordinate2DMake(currLocation.coordinate.latitude + 0.013, currLocation.coordinate.longitude - 0.01)]
            }
            updateZones()
            updateAnnotations()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
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
            annotationView.isDraggable = true
        }
        return annotationView
    }
    
 
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
            case .starting:
                view.dragState = .dragging
            case .ending:
                view.dragState = .none
                let annotation:zoneAnnotation = view.annotation as! zoneAnnotation
                zones[annotation.zoneIndex] = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude)
                zoneAnnotations[annotation.zoneIndex].coordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                updateZones()
            case .canceling:
                view.dragState = .none
            case .dragging:
                break
            case .none:
                break;
        }

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
        zoneAnnotations.removeAll()
        var i=0
        for point in zones{
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
        var locations = zones.map { $0 }
        let polygon:zonePolygon = zonePolygon(coordinates: &locations, count: zones.count)
        if zoneTypeSegment.selectedSegmentIndex == 0{
            polygon.setType(type: .safeZone)
        }else{
            polygon.setType(type: .unSafeZone)
        }
        mainMapView.add(polygon)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickNext() {
        self.startActivityIndicator()
        var polygon:[[String: Double]] = []
        for point in zones {
            polygon.append(["lat": point.latitude , "long": point.longitude])
        }
        user.addZone(name: self.zoneNameField.text!, address: self.zoneAddressField.text!, zones: polygon, safe: 1 - zoneTypeSegment.selectedSegmentIndex)        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height-76
            viewBottomConstraint.constant = keyboardHeight
        }
    }
    
    func keyboardWillBeHidden(_ notification: NSNotification){
        viewBottomConstraint.constant = 0
    }
    
    

}
