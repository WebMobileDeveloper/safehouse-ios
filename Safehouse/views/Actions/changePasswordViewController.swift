//
//  changePasswordViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/3/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class changePasswordViewController: UIViewController {

    @IBOutlet weak var currPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        let curr = currPassField.text!
        let new = newPassField.text!
        let conf = confirmPassField.text!
        
        if curr.count < 6 {
            showAlert(target: self, message: "You must enter your current password more than 6 characters.   Try again!", title: "Alert")
            return
        }
        if curr != user.password{
            showAlert(target: self, message: "The current password you entered is incorrect.    Try again!", title: "Alert")
            return
        }
        if new.count < 6 {
            showAlert(target: self, message: "You must enter your new password more than 6 characters.    Try again!", title: "Alert")
            return
        }
        if new != conf {
            showAlert(target: self, message: "Confirm password doesn't match with new password.   Try again!", title: "Alert")
            return
        }
        user.changePassword(newPassword: new) {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        self.btnSave.layer.cornerRadius = self.btnSave.frame.height/2
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   

}
