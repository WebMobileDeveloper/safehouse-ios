//
//  editZoneViewController.swift
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
    
class editZoneViewController: UIViewController, MKMapViewDelegate ,CustomButtonDelegate{
    
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
    
    var zone:zoneStruct = zoneStruct()
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
            zone.safe = 1
        case 1:  // unsafe zone
            outerSegmentView.borderColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
            sender.tintColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
            zone.safe = 0
        default:
            return
            
        }
        updateZones()
    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        onClickNext()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoneTypeSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)], for: UIControlState())
        zoneTypeSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)], for:.selected)
        zoneTypeSegment.selectedSegmentIndex = 1 - zone.safe
        switch  zoneTypeSegment.selectedSegmentIndex {
        case 0:  // safe zone
            outerSegmentView.borderColor = UIColor(red: 56/255, green: 215/255, blue: 142/255, alpha: 1)
            zoneTypeSegment.tintColor = UIColor(red: 56/255, green: 215/255, blue: 142/255, alpha: 1)
        case 1:  // unsafe zone
            outerSegmentView.borderColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
            zoneTypeSegment.tintColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
        default:
            break
        }
        zoneAddressField.text = zone.address
        zoneNameField.text = zone.name
        
        //MARK: - Setup Map View
        mainMapView.delegate = self
        mainMapView.mapType=MKMapType.standard
        mainMapView.showsUserLocation = true
        let center = getCenter()
        let region = MKCoordinateRegion(center: center, span : span)
        mainMapView.setRegion(region, animated: true)
        
        
        updateZones()
        updateAnnotations()
        
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        
        self.continueInputAccessoryView?.delegate = self as CustomButtonDelegate
        continueInputAccessoryView?.BtnAction.setTitle("Save", for: .normal)
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
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending:
            view.dragState = .none
            let annotation:zoneAnnotation = view.annotation as! zoneAnnotation
            zone.polygon[annotation.zoneIndex] = annotation.coordinate
            zoneAnnotations[annotation.zoneIndex].coordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            updateZones()
        case .canceling:
            view.dragState = .none
            
        case .dragging:
            return
        case .none:
            return
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
        if zoneTypeSegment.selectedSegmentIndex == 0{
            polygon.setType(type: .safeZone)
        }else{
            polygon.setType(type: .unSafeZone)
        }
        mainMapView.add(polygon)
    }
    
    func onClickNext() {
        zone.address = zoneAddressField.text!
        zone.name = zoneNameField.text!
        
        let choiceAlert = UIAlertController(title: "Select type", message: "Are you sure want to save changes?", preferredStyle: UIAlertControllerStyle.alert)
        
        choiceAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            user.updateZone(zone: self.zone, completion: {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                let detailView = viewControllers[viewControllers.count - 2] as! zoneDetailViewController
                detailView.zone = self.zone
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
            })
            
        }))
        
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        self.present(choiceAlert, animated: true, completion: nil)
        
        
    }
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height-71
            viewBottomConstraint.constant = keyboardHeight
        }
    }
    func keyboardWillBeHidden(_ notification: NSNotification){
        viewBottomConstraint.constant = 0
    }
    
  
}
