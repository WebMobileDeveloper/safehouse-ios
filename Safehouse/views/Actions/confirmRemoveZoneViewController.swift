//
//  confirmRemoveZoneViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class confirmRemoveZoneViewController: UIViewController {

    var zoneId:String = ""
    @IBOutlet weak var lblConfirmSentence: UILabel!
    
    @IBAction func onRemoveButtonTapped(_ sender: Any) {
       // Get the presenting/previous view
        user.deleteZone(zoneId: zoneId) {
            let previousView = self.presentingViewController as! UINavigationController
            self.dismiss(animated: true, completion:  {
                // Get an array of the current view controllers on your nav stack
                let viewControllers: [UIViewController] = previousView.viewControllers as [UIViewController]
                previousView.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
            });
        }
    }
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
