//
//  JEEPageControl.swift
//  yuguo
//
//  Created by ZhangJunjee on 15/6/8.
//  Copyright (c) 2015年 yuguo. All rights reserved.
//

import UIKit
struct pageStatic {
    static let kDotDiameterOn:CGFloat = 8
    static let kDotDiameterOff:CGFloat = 8
    static let kDotSpace:CGFloat = 14
}
class JEEPageControl: UIControl, UIScrollViewDelegate {
    
    var pageItem: JEEPageItem!
    var pageScrollView: UIScrollView!
    var BtnStart: UIButton!
    var currentPage: Int = 1
    
    fileprivate var dotArray = [UIView]()
    fileprivate var isClickJump = false
    
    init(item: JEEPageItem!, scrollView: UIScrollView!, BtnStart: UIButton!) {
        super.init(frame: CGRect.zero)
        self.pageItem = item
        self.pageScrollView = scrollView
        self.BtnStart=BtnStart
        self.pageScrollView.delegate = self
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initDotSize() {
        for dotView in self.dotArray {
            dotView.transform = CGAffineTransform.identity
            dotView.backgroundColor = self.pageItem.offColor
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.size.width
        var fractional = fabs((scrollView.contentOffset.x.truncatingRemainder(dividingBy: pageWidth))/pageWidth)
        var forward = false
        if scrollView.contentOffset.x >= CGFloat(self.currentPage - 1) * pageWidth {
            forward = true
        }else {
            if scrollView.contentOffset.x > 0 {
                fractional = 1-fractional
            }
        }
        self.changeToNearDot(forward, progress: fractional)
        let fractionalPage = scrollView.contentOffset.x / pageWidth + 1
        self.currentPage = lround(Double(fractionalPage))
        if self.currentPage == 4 {
            self.BtnStart.isHidden = false
        }else{
            self.BtnStart.isHidden = true
        }
        
    }
   
   
    func setupView() {
        var diameter = self.pageItem.indicatorDiameterOff
        if diameter <= 0 {
            diameter = pageStatic.kDotDiameterOff
        }
        
        let space = self.pageItem.indicatorSpace
        if space <= 0 {
            diameter = pageStatic.kDotSpace
        }
        let offColor = self.pageItem.offColor
        let onColor = self.pageItem.onColor
        
        for i in 0 ..< self.pageItem.numberOfPages {
            
            let dotView = UIView(frame: CGRect(x: CGFloat(i)*diameter+CGFloat(i)*space, y: 0, width: diameter, height: diameter))
            dotView.layer.cornerRadius = diameter/2
            dotView.backgroundColor = offColor
            dotView.tag = i+1
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(JEEPageControl.tapDotView(_:)))
            dotView.addGestureRecognizer(tapGesture)
            self.addSubview(dotView)
            self.dotArray.append(dotView)
        }
        if self.pageItem.numberOfPages > 0 {
            let bigTransform = self.pageItem.indicatorDiameterOn/self.pageItem.indicatorDiameterOff
            self.dotArray[0].transform = CGAffineTransform(scaleX: bigTransform, y: bigTransform)
            self.dotArray[0].backgroundColor = onColor
        }
    }
    
    func tapDotView(_ gesture: UITapGestureRecognizer) {
        self.isClickJump = true
        let dotView = gesture.view!
        let pageWidth = self.pageScrollView.bounds.size.width * CGFloat(dotView.tag - 1)
        self.pageScrollView.scrollRectToVisible(CGRect(x: pageWidth, y: self.pageScrollView.frame.origin.y, width: self.pageScrollView.frame.size.width, height: self.pageScrollView.frame.size.height), animated: true)
        self.sendActions(for: UIControlEvents.valueChanged)
    }
    
    func changeToNearDot(_ forward: Bool, progress: CGFloat) {
        var toDotView: UIView?
        if forward&&self.currentPage < self.dotArray.count {
            toDotView = self.dotArray[self.currentPage]
        }else if !forward&&self.currentPage > 1 {
            toDotView = self.dotArray[self.currentPage - 2]
        }
        let fromDotView = self.dotArray[self.currentPage - 1]
        let diffTransform = (self.pageItem.indicatorDiameterOn - self.pageItem.indicatorDiameterOff)/self.pageItem.indicatorDiameterOff

        if progress > 0 && progress < 1 {
            let offColor = self.pageItem.offColor
            let onColor = self.pageItem.onColor
            if toDotView != nil {
                toDotView!.transform = CGAffineTransform(scaleX: 1+diffTransform*progress, y: 1+diffTransform*progress)
                
                toDotView?.backgroundColor = self.colorTransformToAnother(offColor, toColor: onColor, progress: progress)
            }
            fromDotView.transform = CGAffineTransform(scaleX: (1 + diffTransform)-diffTransform*progress, y: (1 + diffTransform)-diffTransform*progress)
            fromDotView.backgroundColor = self.colorTransformToAnother(onColor, toColor: offColor, progress: progress)
        }
    }
    
    func colorTransformToAnother(_ fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> UIColor {
        let fromRGB = fromColor.cgColor.components
        let toRGB = toColor.cgColor.components
        let red = (fromRGB?[0])! + ((toRGB?[0])! - (fromRGB?[0])!)*progress
        let green = (fromRGB?[1])! + ((toRGB?[1])! - (fromRGB?[1])!)*progress
        let blue = fromRGB![2] + ((toRGB?[2])! - fromRGB![2])*progress
        let alpha = fromRGB![3] + ((toRGB?[3])! - fromRGB![3])*progress
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

class JEEPageItem {
    var numberOfPages: Int!
    var onColor: UIColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    var offColor: UIColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 0.4)
    var indicatorDiameterOn: CGFloat = pageStatic.kDotDiameterOn
    var indicatorDiameterOff: CGFloat = pageStatic.kDotDiameterOff
    var indicatorSpace: CGFloat = pageStatic.kDotSpace
    var hideForSignlePage: Bool = true
    var width:CGFloat = 0
    var height:CGFloat = 20
    init(pageNum: Int) {
        self.numberOfPages = pageNum
        self.width=(CGFloat)(pageNum-1) * (self.indicatorDiameterOff+self.indicatorSpace)
        self.width += self.indicatorDiameterOn
    }
}
