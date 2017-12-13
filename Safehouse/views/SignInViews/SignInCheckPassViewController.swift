//
//  SignInCheckPassViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/22/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class SignInCheckPassViewController: UIViewController,CustomButtonDelegate {
    @IBAction func signout(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//            //KeychainWrapper.standard.removeAllKeys()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
    }
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var BtnContinue: UIButton!
    var continueInputAccessoryView : CustomAccessoryView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*         // MARK: - Add Continue button to keyboard
         */
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        self.continueInputAccessoryView?.delegate = self as CustomButtonDelegate
        self.passwordField.inputAccessoryView = continueInputAccessoryView
        continueInputAccessoryView?.frame.size = CGSize(width: Global.screenWidth, height: Global.screenHeight * 74 / 667)
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func viewDidLayoutSubviews() {
        /*         // MARK: - Set View Styles
         */
        self.passwordField.layer.cornerRadius = self.passwordField.frame.height/2
        self.BtnContinue.layer.cornerRadius = self.BtnContinue.frame.height / 2
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /*     // MARK: - customButton protocal functions
     */
    func pushForgotView() {
        if let viewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInForgotViewController") as? SignInForgotViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    func pushNextView() {
        if passwordField.text == "" {
            showAlert(target: self, message: "Password field is required", title: "Warning")
            return
        }
        if (passwordField.text?.count)! < 6 {
            showAlert(target: self, message: "Password should be at least 6 characters", title: "Warning")
            return
        }        
        user.signIn(password: passwordField.text!)
    }
    func onClickNext() {
        pushNextView()
    }
    
    @IBAction func onClickContinue(_ sender: Any) {
        pushNextView()
    }
    
    @IBAction func onForgotTapped(_ sender: Any) {
        pushForgotView()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
