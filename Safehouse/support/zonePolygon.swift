//
//  zonePolygon.swift
//  Safehouse
//
//  Created by Delicious on 9/25/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import Foundation
import MapKit

enum zoneType{
    case safeZone
    case unSafeZone
}
class zonePolygon : MKPolygon{
    var type:zoneType = .safeZone
    
    public func setType(type:zoneType){
        self.type =  type
    }
    
}


enum lineType{
    case general
    case arrow
}
class CustomPolyline : MKPolyline{
    var type:lineType = .general
    
    public func setType(type:lineType){
        self.type =  type
    }
}

class zoneAnnotation:MKPointAnnotation{
    var zoneIndex:Int = 0
}

func PointAtBearingFromPoint(center:CLLocation, theta: Float, R: Float)->CLLocation{
    let lat = center.coordinate.latitude
    let long = center.coordinate.longitude
    
    let dx = Double(R) * cos(Double(theta))
    let dy = Double(R) * sin(Double(theta))
    
    let radLat : CGFloat = Double(lat).degreesToRadians
    
    let deltaLongitude = dx/(111320 * Double(cos(radLat)))
    let deltaLatitude = dy/110540
    
    let endLat = lat + deltaLatitude
    let endLong = long + deltaLongitude
    
    
    
    return CLLocation(latitude: endLat, longitude: endLong)
}
