//
//  editProfileViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/2/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class editProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,CountriesViewControllerDelegate {
    
    var imageChanged = false
    public var country = Country(countryCode: "US", phoneExtension: "+1", isMain: true) //Country.currentCountry
    
    public var phoneNumber: String? {
        if let countryText = countryField.text, let phoneNumberText = phoneField.text, !countryText.isEmpty && !phoneNumberText.isEmpty {
            return countryText + phoneNumberText
        }
        return nil
    }
    
    
    
    //@IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet var viewChangePassword: UIView!
    @IBOutlet weak var viewDeleteAccount: UIView!
    @IBOutlet var btnSaveChange: UIView!
    @IBOutlet weak var BtnAddPhoto: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.changePassword(_:)))
        viewChangePassword.addGestureRecognizer(tap)
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.deleteAccount(_:)))
        viewDeleteAccount.addGestureRecognizer(tap1)
        
        nameField.text = user.name
        emailField.text = user.email
        country = Countries.countryFromCountryCode(user.country_code)
        phoneField.text = user.number_part
        updateCountry()
        
        if user.photo_url != "" {
            let url = URL(string:user.photo_url)
            let data = try? Data(contentsOf: url!)
            if data != nil{
                profileImage.image = UIImage(data: data!)
                BtnAddPhoto.setTitle("Change Photo", for: .normal)
            }else{
                profileImage.image = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
            }
        }else{
            profileImage.image = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        stopActivityIndicator()
    }
    override func viewDidLayoutSubviews() {
        self.btnSaveChange.layer.cornerRadius = self.btnSaveChange.frame.height/2
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func changePassword(_ sender:UITapGestureRecognizer){
        changePassTapped()
    }
    func deleteAccount(_ sender:UITapGestureRecognizer){
        deleteAccountTapped()
    }
    func changePassTapped() {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "changePasswordViewController") as? changePasswordViewController {
            if let navigator = self.navigationController {
                //viewController.childName = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    func deleteAccountTapped() {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "deleteAccountViewController") as? deleteAccountViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    /*  Mark: ImagePickerControllerdelegate functions
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        /*   select origin image  */
//                 image.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//                 self.dismiss(animated: true, completion: nil)
//
//
        /* select edited image   */
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = chosenImage.resizeAndCompress(newWidth: PROFILE_IMAGE_WIDTH, maxSize: MAX_UPLOAD_IMAGE_SIZE)
            print("------image changed")
        }
        BtnAddPhoto.setTitle("Change Photo", for: .normal)
        imageChanged = true
        self.dismiss(animated: true, completion: nil);
    }
    
    /*
     // MARK: - CountriesViewControllerDelegate functions
     
     */
    public func countriesViewControllerDidCancel(_ countriesViewController: CountriesViewController) { }
    
    public func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountry country: Country) {
        
        self.dismiss(animated: true, completion: nil)
        
        self.country = country
        updateCountry()
    }
    
    /*     // MARK: - country Text Field functions
     */
    
    fileprivate func updateCountry() {
        self.countryField.text = country.phoneExtension
        updateCountryTextField()
        updateTitle()
    }
    fileprivate func updateTitle() {
        updateCountryTextField()
        if self.countryField.text == "+" {
            countryButton.setTitle(" ▼", for: UIControlState())
        } else {
            countryButton.setTitle(" ▼\(country.countryCode)", for: UIControlState())
        }
    }
    
    fileprivate func updateCountryTextField() {
        if self.countryField.text == "+" {
            self.countryField.text = ""
        }
        else if let countryText = self.countryField.text, !countryText.hasPrefix("+") && !countryText.isEmpty {
            self.countryField.text = "+" + countryText
        }
    }
    
    /*
     // MARK: - Validation functions
     
     */
    public var countryIsValid: Bool {
        if let countryCodeLength = countryField.text?.count {
            return country != Country.emptyCountry && countryCodeLength > 1 && countryCodeLength < 5
        }
        return false
    }
    
    public var phoneNumberIsValid: Bool {
        if let phoneNumberLength = phoneField.text?.count{
            return phoneNumberLength > 5 && phoneNumberLength < 15
        }
        return false
    }

    @IBAction fileprivate func changeCountry(_ sender: UIButton) {
        let countriesViewController = CountriesViewController.standardController()
        countriesViewController.delegate = self
        countriesViewController.selectedCountry = country
        countriesViewController.majorCountryLocaleIdentifiers = ["GB", "US", "IT", "DE", "RU", "BR", "IN"]
        let navC = UINavigationController.init(rootViewController: countriesViewController)
        self.present(navC, animated: true, completion: nil)
    }
    
    @IBAction fileprivate func CountryFieldDidChangeText(_ sender: UITextField) {
        if let countryText = sender.text, sender == countryField {
            country = Countries.countryFromPhoneExtension(countryText)
        }
        updateTitle()
    }

    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    @IBAction func onChangePasswordClick(_ sender: Any) {
        changePassTapped()
    }
    
    @IBAction func onDeleteAccountClick(_ sender: Any) {
        deleteAccountTapped()
    }
    
    /*             //MARK: - Show Image Picker             */
    @IBAction func addPhotoBtnTapped(_ sender: Any) {
       showChoiceAlert(target: self)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if !checkEmail(testStr: emailField.text!) {
            showAlert(target: self, message: "Please input correct email.", title: "Incorrect email!")
            return
        }
        if user.email != emailField.text{
            let alert = UIAlertController(title: "Confirm", message: "Are you sure want to change email address?", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.updateProfile()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        
        } else {
            updateProfile()
        }
    }
    func updateProfile() {
        if imageChanged{
            user.updateUserImage(newImage: profileImage.image!, uid: user.uid , completion: { (photo_url) in
                var values:[String:String] = [:]
                
                self.imageChanged = false
                values["photo_url"] = photo_url
                
                if user.email != self.emailField.text{
                    user.changeEmail(newEmail: self.emailField.text! , completion: { (result) in
                        if result {
                            values["email"] = self.emailField.text
                        }
                        if user.name != self.nameField.text{
                            values["name"] = self.nameField.text
                        }
                        if user.phone != self.phoneNumber && self.phoneNumberIsValid{
                            values["phone"] = self.phoneNumber
                            values["country_code"] = self.country.countryCode
                            values["number_part"] = self.phoneField.text
                        }
                        user.updateUserData(values: values, uid: user.uid, completion: {
                            //self.stopActivityIndicator()
                            showAlert(target: self, message: "Your changes are saved successfully!")
                        })
                    })
                }else{
                    if user.name != self.nameField.text{
                        values["name"] = self.nameField.text
                    }
                    if user.phone != self.phoneNumber && self.phoneNumberIsValid{
                        values["phone"] = self.phoneNumber
                        values["country_code"] = self.country.countryCode
                        values["number_part"] = self.phoneField.text
                    }
                    user.updateUserData(values: values, uid: user.uid, completion: {
                        //self.stopActivityIndicator()
                        showAlert(target: self, message: "Your changes are saved successfully!")
                    })
                }
            })
        }else{
            var values:[String:String] = [:]
            if user.email != self.emailField.text{
                user.changeEmail(newEmail: emailField.text! , completion: { (result) in
                    if result {
                        values["email"] = self.emailField.text
                    }
                    if user.name != self.nameField.text{
                        values["name"] = self.nameField.text
                    }
                    if user.phone != self.phoneNumber && self.phoneNumberIsValid{
                        values["phone"] = self.phoneNumber
                        values["country_code"] = self.country.countryCode
                        values["number_part"] = self.phoneField.text
                    }
                    user.updateUserData(values: values, uid: user.uid, completion: {
                        //self.stopActivityIndicator()
                        showAlert(target: self, message: "Your changes are saved successfully!")
                    })
                })
            }else{
                if user.name != self.nameField.text{
                    values["name"] = self.nameField.text
                }
                if user.phone != self.phoneNumber && self.phoneNumberIsValid{
                    values["phone"] = self.phoneNumber
                    values["country_code"] = self.country.countryCode
                    values["number_part"] = self.phoneField.text
                }
                if values.isEmpty{
                    showAlert(target: self, message: "We can't find any changes.", title: "Alert")
                    return
                }
                user.updateUserData(values: values, uid: user.uid, completion: {
                    //self.stopActivityIndicator()
                    showAlert(target: self, message: "Your changes are saved successfully!")
                })
            }
        }
    }
    func checkEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
