//
//  SignUppasswordViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/19/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class SignUpPasswordViewController: UIViewController, CustomButtonDelegate {
    var continueInputAccessoryView : CustomAccessoryView?
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var BtnContinue: UIButton!
    
    @IBAction func passwordChanged(_ sender: Any) {
        confirmField.text = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*    // MARK: - Add Continue button to keyboard */
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        self.continueInputAccessoryView?.delegate = self as CustomButtonDelegate
        self.confirmField.inputAccessoryView = continueInputAccessoryView
        continueInputAccessoryView?.frame.size = CGSize(width: Global.screenWidth, height: Global.screenHeight * 74 / 667)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        passwordField.text = user.password
        confirmField.text = user.password
    }
    override func viewDidLayoutSubviews() {
        self.passwordField.layer.cornerRadius = self.passwordField.frame.height/2
        self.confirmField.layer.cornerRadius = self.confirmField.frame.height/2
        self.BtnContinue.layer.cornerRadius = self.BtnContinue.frame.height / 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*     // MARK: - customButton protocal functions       */
    
    func checkPassword() -> String {
        if passwordField.text == ""{
            return "empty"
        }
        if (passwordField.text?.count)! < 6{
            return "short"
        }
        if passwordField.text == confirmField.text{
            return "matched"
        }else{
            return "unmatched"
        }
    }
    func pushNextView() {
        switch checkPassword() {
        case "empty":
            showAlert(target: self, message: "Password field is required!")
        case "unmatched":
            showAlert(target: self, message: "Unmatched password")
        case "short":
            showAlert(target: self, message: "Password should be at least 6 characters")
        default:
            user.password = passwordField.text!
            user.updateState()
            user.switchFromState()
        }
    }
    func onClickNext() {
        pushNextView()
    }
    @IBAction func onClickContinue(_ sender: Any) {
        pushNextView()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
