//
//  familyAnnotation.swift
//  Safehouse
//
//  Created by Delicious on 9/25/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import Foundation
import MapKit

enum annotationType{
    case child(name: String)
    case parent(name: String)
    func description() -> String {
        switch self {
        case .child:
            return "child"
        default:
            return "parent"
        }
    }
}
class familyAnnotation : MKPointAnnotation{
    var image:UIImage = UIImage()
    var type: annotationType = .parent(name:"")
    var uid:String = ""
}

extension UIImage {
    class func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
        
        let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  = round((newImageSize.width  - firstImage.size.width  ) / 2)
        let firstImageDrawY  = round((newImageSize.height - firstImage.size.height ) / 2)
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = round((newImageSize.height - secondImage.size.height) / 2)
        
        firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    class func onePersonAnnotationImage(frameImage: UIImage, profileImage:UIImage)->UIImage{
        let newImageWidth  = frameImage.size.width
        let newImageHeight = frameImage.size.height
        let newImageSize = frameImage.size
        
        var newWidth = profileImage.size.width
        if newWidth > profileImage.size.height{
            newWidth = profileImage.size.height
        }
        var newProfileImage = cropToBounds(image: profileImage, width: newWidth, height: newWidth)
        newProfileImage = maskRoundedImage(image: newProfileImage!, radius: newWidth/2)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        frameImage.draw(in: CGRect(x: 0, y: 0, width: newImageWidth, height: newImageHeight))
        newProfileImage?.draw(in: CGRect(
            x: round(newImageWidth * 0.16),
            y: round(newImageHeight * 0.0592),
            width: round(newImageWidth * 0.613),
            height: round(newImageWidth * 0.613)))
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    class func twoPersonAnnotationImage(frameImage: UIImage, profileImage1:UIImage, profileImage2: UIImage)->UIImage{
        let newImageWidth  = frameImage.size.width
        let newImageHeight = frameImage.size.height
        let newImageSize = frameImage.size
        
        var newWidth1 = profileImage1.size.width
        if newWidth1 > profileImage1.size.height{
            newWidth1 = profileImage1.size.height
        }
        var newWidth2 = profileImage2.size.width
        if newWidth2 > profileImage2.size.height{
            newWidth2 = profileImage2.size.height
        }
        var newProfileImage1 = cropToBounds(image: profileImage1, width: newWidth1, height: newWidth1)
        newProfileImage1 = maskRoundedImage(image: newProfileImage1!, radius: newWidth1/2)
        var newProfileImage2 = cropToBounds(image: profileImage2, width: newWidth2, height: newWidth2)
        newProfileImage2 = maskRoundedImage(image: newProfileImage2!, radius: newWidth2/2)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        frameImage.draw(in: CGRect(x: 0, y: 0, width: newImageWidth, height: newImageHeight))
        newProfileImage1?.draw(in: CGRect(
            x: newImageWidth * 0.1,
            y: newImageHeight * 0.05,
            width: newImageWidth * 0.363,
            height: newImageWidth * 0.363))
        newProfileImage2?.draw(in: CGRect(
            x: newImageWidth * 0.508,
            y: newImageHeight * 0.05,
            width: newImageWidth * 0.363,
            height: newImageWidth * 0.363))
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func resizeAndCompress(newWidth:CGFloat, maxSize:Int)->UIImage{
        var newImage:UIImage = resizeImage(image: self, newWidth: newWidth)!
        var compression:CGFloat = 1
        var imageData:Data = UIImageJPEGRepresentation(newImage, compression)!
        while (imageData.count > maxSize && compression > 0.5) {
            compression -= 0.1
            imageData = UIImageJPEGRepresentation(newImage, compression)!
        }
        newImage = UIImage(data: imageData)!
        return newImage
    }
}

func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage {
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    layer.masksToBounds = true
    layer.cornerRadius = radius
    UIGraphicsBeginImageContext(imageView.bounds.size)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return roundedImage!
}

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
    let contextSize: CGSize = image.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = width
    var cgheight: CGFloat = height
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    let rect:CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    guard let imageRef = image.cgImage?.cropping(to: rect) else {
        return nil
    }
    let croppedImage = UIImage(cgImage:imageRef)
    return croppedImage
}
func cropToRect(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
    let contextSize: CGSize = image.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    posX = ((contextSize.width - width) / 2)
    posY = ((contextSize.height - height) / 2)
    let rect:CGRect = CGRect(x: posX, y: posY, width: width, height: height)
    
    guard let imageRef = image.cgImage?.cropping(to: rect) else {
        return nil
    }
    let croppedImage = UIImage(cgImage:imageRef)
    return croppedImage
}


