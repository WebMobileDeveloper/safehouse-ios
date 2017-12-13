//
//  SignUpPhoneViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/19/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class SignUpInviteViewController: UIViewController {
    @IBOutlet weak var BtnShareCode: UIButton!
    @IBOutlet weak var BtnContinue: UIButton!
    @IBOutlet weak var LblCode: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        self.LblCode.text = user.family_id != "" ? user.family_id : "- - - - - -"
        //check whether Family for invite code is exist
        if user.family_id != "" {
            let alert = UIAlertController(title: "Alert", message: "You have already created your family group.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.dismiss(animated: true, completion: nil)
                user.switchFromState()
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            user.createFamily()
        }
    }
    override func viewDidLayoutSubviews() {
        self.BtnShareCode.layer.cornerRadius = self.BtnShareCode.frame.height / 2
        self.BtnContinue.layer.cornerRadius = self.BtnContinue.frame.height / 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    /*     // MARK: - customButton protocal functions
     */
    func pushNextView() {
        /*    //MARK: - Email Validation Checking            */
        if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpPermissionViewController") as? SignUpPermissionViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onClickShareCode(_ sender: Any) {
        let textToShare = [ LblCode.text! ]
        // UIActivityViewController setup
        let activityVC = UIActivityViewController(activityItems: textToShare, applicationActivities: [])
        activityVC.popoverPresentationController?.sourceView = self.view
        
        //activityVC.excludedActivityTypes = [ UIActivityType.airDrop ]
        
        self.present(activityVC, animated: true, completion: nil)
    }
    @IBAction func onClickContinue(_ sender: Any) {
        pushNextView()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
