//
//  confirmRemoveMemberViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class confirmRemoveMemberViewController: UIViewController {
    var name:String = "Susie"
    @IBOutlet weak var lblConfirmSentence: UILabel!

    @IBAction func onRemoveButtonTapped(_ sender: Any) {
        let previousView = self.presentingViewController as! UINavigationController
        
        self.dismiss(animated: true, completion:  {
            // Get an array of the current view controllers on your nav stack
            let viewControllers: [UIViewController] = previousView.viewControllers as [UIViewController]
            previousView.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
            
        });
    }
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblConfirmSentence.text = "Are you sure you want to remove \(name) from the group?"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
}
