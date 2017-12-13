//
//  deleteAccountViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/3/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class deleteAccountViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var btnDeleteAccount: UIButton!
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    @IBAction func onDeleteButtonClick(_ sender: Any) {
        if passwordField.text?.count == 0 {
            showAlert(target: self, message: "Please input your current password.", title: "Warning")
            return
        }
        if passwordField.text != user.password {
            showAlert(target: self, message: "Please input your correct password.", title: "Warning")
            return
        }
        user.deleteAccount {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartViewController") as? StartViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        passwordField.layer.cornerRadius = passwordField.frame.height / 2
        btnDeleteAccount.layer.cornerRadius = btnDeleteAccount.frame.height / 2
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
