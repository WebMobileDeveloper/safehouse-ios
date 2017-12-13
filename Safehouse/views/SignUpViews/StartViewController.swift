//
//  StartViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/18/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit


class StartViewController: UIViewController, UIScrollViewDelegate {
  
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet weak var BtnStart: UIButton!
    
    var pageControl: JEEPageControl!
    var scrollWidth : CGFloat = UIScreen.main.bounds.size.width
    var scrollHeight : CGFloat = UIScreen.main.bounds.size.height
    let imageCount:Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.contentSize = CGSize(width: (scrollWidth * 4), height: scrollHeight)
        scrollView?.isPagingEnabled=true
        scrollView?.isDirectionalLockEnabled = true
        
        for i in 0...self.imageCount {
            let imgView = UIImageView.init()
            imgView.frame = CGRect(x: scrollWidth * CGFloat (i), y: 0, width: scrollWidth,height: scrollHeight)
            switch i {
                case 0:
                    imgView.image = #imageLiteral(resourceName: "Walkthrough 1")
                case 1:
                    imgView.image = #imageLiteral(resourceName: "Walkthrough 2")
                case 2:
                    imgView.image = #imageLiteral(resourceName: "Walkthrough 3")
                case 3:
                    imgView.image = #imageLiteral(resourceName: "Walkthrough 5")
                default:
                    imgView.image = nil
            }
            scrollView?.addSubview(imgView)
        }
        
        //MARK: -  Page Control part
        let item = JEEPageItem(pageNum: self.imageCount)
        self.pageControl = JEEPageControl(item: item, scrollView: self.scrollView, BtnStart: self.BtnStart)
        let xPosi = self.view.frame.width/2 - item.width / 2
        let yPosi = self.view.frame.height - item.height-20
        self.pageControl.frame = CGRect(x: xPosi, y: yPosi, width: item.width , height: item.height)
        
        self.view.addSubview(pageControl)
        self.pageControl.currentPage = 1
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func onBtnStartClick(_ sender: Any) {
        user.switchFromState()
    }
    
}
