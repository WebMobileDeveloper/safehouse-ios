//
//  SignUpEmailViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/21/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import FirebaseAuth
class SignInForgotViewController: UIViewController,CustomButtonDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var BtnContinue: UIButton!
    var continueInputAccessoryView : CustomAccessoryView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*         // MARK: - Add Continue button to keyboard
         */
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        
        self.continueInputAccessoryView?.delegate = self as CustomButtonDelegate
        continueInputAccessoryView?.BtnAction.setTitle("SEND", for: .normal)
        self.emailField.inputAccessoryView = continueInputAccessoryView
        continueInputAccessoryView?.frame.size = CGSize(width: Global.screenWidth, height: Global.screenHeight * 74 / 667)
        
    }
    override func viewDidLayoutSubviews() {
        /*         // MARK: - Set View Styles
         */
        self.emailField.layer.cornerRadius = self.emailField.frame.height/2
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
    func checkEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func pushNextView() {
        if checkEmail(testStr: self.emailField.text!) {
            if(self.emailField.text != user.email){
                showAlert(target: self, message: "Enter your correct email address.", title: "Error")
                return
            }
            Auth.auth().sendPasswordReset(withEmail: "self.emailField.text") { (error) in
                if error != nil{
                    if let viewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInSentForgotViewController") as? SignInSentForgotViewController {
                        if let navigator = self.navigationController {
                            viewController.emailAddress = self.emailField.text!
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                }else{
                    showAlert(target: self, message: "Enter your correct email address.", title: "Error")
                }
            }
        }else{
            showAlert(target: self, message: "Please insert a valid email address.")
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
