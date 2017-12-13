//
//  customAccessoryView.swift
//  Safehouse
//
//  Created by Delicious on 9/20/17.
//  Copyright © 2017 Delicious. All rights reserved.
//
import UIKit

protocol CustomButtonDelegate:class {
    func onClickNext()
}

class CustomAccessoryView: UIView {
    
    @IBOutlet weak var BtnAction: UIButton!
    var delegate : CustomButtonDelegate?
    
    @IBAction func clickLoveButton(_ sender: UIButton) {
        
        self.delegate?.onClickNext()
    }
    
}
