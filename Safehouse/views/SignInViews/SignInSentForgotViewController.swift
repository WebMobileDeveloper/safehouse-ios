//
//  SignInSentForgotViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/22/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class SignInSentForgotViewController: UIViewController {
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var BtnLogin: UIButton!
    var emailAddress : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblResult.text = "Your password reset email was successfully sent to \(self.emailAddress)"
    }
    override func viewDidLayoutSubviews() {
        self.BtnLogin.layer.cornerRadius = self.BtnLogin.frame.height / 2
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*     // MARK: - customButton protocal functions
     */
    func pushNextView() {
        if let viewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInCheckPassViewController") as? SignInCheckPassViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    

    @IBAction func onClickLogin(_ sender: Any) {
        pushNextView()
    }

    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
