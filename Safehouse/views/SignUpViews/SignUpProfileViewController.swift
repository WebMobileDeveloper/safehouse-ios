//
//  SignUpnameViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/21/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class SignUpProfileViewController: UIViewController,CustomButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var BtnContinue: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var BtnAddPhoto: UIButton!
    var continueInputAccessoryView : CustomAccessoryView?
    var imageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*         // MARK: - Add Continue button to keyboard         */
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        self.continueInputAccessoryView?.delegate = self as CustomButtonDelegate
        self.nameField.inputAccessoryView = continueInputAccessoryView
        continueInputAccessoryView?.frame.size = CGSize(width: Global.screenWidth, height: Global.screenHeight * 74 / 667)
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        nameField.text = user.name
        if user.photo_url != ""{
            let url = URL(string:user.photo_url)
            let data = try? Data(contentsOf: url!)
            if data != nil {
                image.image = UIImage(data: data!)
                BtnAddPhoto.setTitle("Change Photo", for: .normal)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        self.nameField.layer.cornerRadius = self.nameField.frame.height / 2
        self.BtnContinue.layer.cornerRadius = self.BtnContinue.frame.height / 2
        image.layer.masksToBounds = false
        image.layer.cornerRadius = image.frame.height / 2
        image.clipsToBounds = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /*  Mark: ImagePickerControllerdelegate functions
    */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
//        /*   select origin image  */
//                image.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//                self.dismiss(animated: true, completion: nil)
 
        
        /* select edited image   */
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image.image = chosenImage.resizeAndCompress(newWidth: PROFILE_IMAGE_WIDTH, maxSize: MAX_UPLOAD_IMAGE_SIZE)
        }
        self.dismiss(animated: true, completion: nil);
        BtnAddPhoto.setTitle("Change Photo", for: .normal)
        imageChanged = true
    }
    
    
    /*     // MARK: - customButton protocal functions
     */
    func checkName(testStr:String) -> Bool {
        if testStr.count > 0 {
            return true
        }else{
            return false
        }
    }
    func pushNextView() {
        if checkName(testStr: self.nameField.text!) {
            if imageChanged {
                imageChanged = false
                user.updateUserImage(newImage: image.image!, uid: user.uid, completion: { (photo_url) in
                    var values:[String:String] = ["photo_url": photo_url]
                    if user.name != self.nameField.text{
                        values["name"] = self.nameField.text!
                    }
                    user.updateUserData(values: values, uid: user.uid, completion: {
                        user.switchFromState()
                    })
                })
            }else{
                if user.name != self.nameField.text{
                    let values:[String:String] = ["name": self.nameField.text!]
                    user.updateUserData(values: values, uid: user.uid, completion: {
                        user.switchFromState()
                    })
                }else{
                    user.switchFromState()
                }
            }
        }else{
            showAlert(target: self, message: "Please insert your name.")
        }
    }   
    
    func onClickNext() {
        pushNextView()
    }
    /*             //MARK: - Show Image Picker             */
    @IBAction func addPhotoBtnTapped(_ sender: Any) {
        showChoiceAlert(target: self)
    }    
    @IBAction func onClickContinue(_ sender: Any) {
        pushNextView()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
}
