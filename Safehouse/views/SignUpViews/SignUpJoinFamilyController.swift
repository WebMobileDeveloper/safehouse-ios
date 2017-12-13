//
//  SignUpPhoneViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/19/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
class SignUpJoinFamilyViewController: UIViewController,CustomButtonDelegate {
    @IBOutlet weak var BtnCreateGroup: UIButton!
    @IBOutlet weak var inviteCodeField: UITextField!
    @IBOutlet weak var BtnContinue: UIButton!
    var continueInputAccessoryView : CustomAccessoryView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: -  add button to keyboard
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        self.continueInputAccessoryView?.delegate=self
        self.inviteCodeField.inputAccessoryView = continueInputAccessoryView
        continueInputAccessoryView?.frame.size = CGSize(width: Global.screenWidth, height: Global.screenHeight * 74 / 667)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        if user.family_id != "" {
            let alert = UIAlertController(title: "Alert", message: "You are already joined to your family group.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.dismiss(animated: true, completion: nil)
                user.switchFromState()
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLayoutSubviews() {
        self.BtnCreateGroup.layer.cornerRadius = self.BtnCreateGroup.frame.height / 2
        self.BtnContinue.layer.cornerRadius = self.BtnContinue.frame.height / 2
        self.inviteCodeField.layer.cornerRadius = self.inviteCodeField.frame.height/2
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    func pushInviteView() {
        /*            //MARK: - Email Validation Checking            */
        if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpInviteViewController") as? SignUpInviteViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func pushSignInView(){
        let invite_code:String = inviteCodeField.text!
        if invite_code.count != 6 {
            showAlert(target: self, message: "Please enter 6 characters invite code.")
        } else {
            user.joinFamily(invite_code: invite_code)
        }
    }
    func onClickNext() {
        pushSignInView()
    }
    @IBAction func onClickCreateGroup(_ sender: Any) {
        pushInviteView()
    }
    @IBAction func onClickContinue(_ sender: Any) {
        pushSignInView()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
