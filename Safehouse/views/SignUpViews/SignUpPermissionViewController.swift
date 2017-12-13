//
//  SignUpPhoneViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/19/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class SignUpPermissionViewController: UIViewController {
    @IBOutlet weak var BtnConfirm: UIButton!
    @IBOutlet weak var LblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        self.BtnConfirm.layer.cornerRadius = self.BtnConfirm.frame.height / 2
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }    
    
    func pushNextView() {
        if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapFamilyViewController") as? MapFamilyViewController {
            if let navigator = self.navigationController {
                user.signUpFinished = true
                user.updateState()
                user.updateKeychainWrapper()
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func onClickConfirm(_ sender: Any) {
        pushNextView()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
