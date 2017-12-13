//
//  SignUpPhoneViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/19/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import UIKit

class SignUpPhoneViewController: UIViewController, CountriesViewControllerDelegate, CustomButtonDelegate{
    
    @IBOutlet weak var BtnFacebook: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var BtnContinue: UIButton!
    
    var continueInputAccessoryView : CustomAccessoryView?
    
    public var country = Country(countryCode: "US", phoneExtension: "+1", isMain: true)
    public var phoneNumber: String {
        if let countryText = countryField.text, let phoneNumberText = phoneField.text, !countryText.isEmpty && !phoneNumberText.isEmpty {
            return countryText + phoneNumberText
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCountry()
        //add button to keyboard
        self.continueInputAccessoryView = Bundle.main.loadNibNamed("CustomAccessoryView", owner: self, options: nil)?.first  as? CustomAccessoryView
        self.continueInputAccessoryView?.delegate=self
        
        self.phoneField.inputAccessoryView = continueInputAccessoryView
        self.countryField.inputAccessoryView = continueInputAccessoryView
        continueInputAccessoryView?.frame.size = CGSize(width: Global.screenWidth, height: Global.screenHeight * 74 / 667)
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
        self.stopActivityIndicator()
        if user.userState == .hasFacebookId {
            let alert = UIAlertController(title: "Alert", message: "You have already logined with Facebook", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in              
                self.dismiss(animated: true, completion: nil)
                user.switchFromState()
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            user.switchFromState()
        }
    }
    override func viewDidLayoutSubviews() {
        self.BtnFacebook.layer.cornerRadius = self.BtnFacebook.frame.height / 2
        self.phoneView.layer.cornerRadius = self.phoneView.frame.height/2
        self.BtnContinue.layer.cornerRadius = self.BtnContinue.frame.height / 2
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    
    /*   // MARK: - Firebase facebook login
     start
     */
    @IBAction func facebookLoginButtonTapped(_ sender: Any) {
        user.signUpWithFacebook()
    }

    
     /*   // MARK: - country  functions */
    @IBAction fileprivate func changeCountry(_ sender: UIButton) {
        let countriesViewController = CountriesViewController.standardController()
        countriesViewController.delegate = self
        countriesViewController.selectedCountry = country
        countriesViewController.majorCountryLocaleIdentifiers = ["US", "GB", "IT", "DE", "RU", "BR", "IN"]
        
        let navC = UINavigationController.init(rootViewController: countriesViewController)
        self.present(navC, animated: true, completion: nil)
    }

    @IBAction fileprivate func CountryFieldDidChangeText(_ sender: UITextField) {
        if let countryText = sender.text, sender == countryField {
            country = Countries.countryFromPhoneExtension(countryText)
        }
        updateTitle()
    }
    
    fileprivate func updateCountry() {
        self.countryField.text = country.phoneExtension
        updateCountryTextField()
        updateTitle()
    }
    fileprivate func updateTitle() {
        updateCountryTextField()
        if self.countryField.text == "+" {
            countryButton.setTitle("  ▼", for: UIControlState())
        } else {
            countryButton.setTitle("\(country.countryCode) ▼", for: UIControlState())
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
    
    
    /*    // MARK: - CountriesViewControllerDelegate functions
    */
    public func countriesViewControllerDidCancel(_ countriesViewController: CountriesViewController) { }
    
    public func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountry country: Country) {
        self.dismiss(animated: true, completion: nil)
        self.country = country
        updateCountry()
    }
    
    
    /*     // MARK: - Validation functions
     */
    public var countryIsValid: Bool {
        if let countryCodeLength = countryField.text?.count {
            return country != Country.emptyCountry && countryCodeLength > 1 && countryCodeLength < 5
        }
        return false
    }
    var phoneNumberIsValid: Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phoneNumber)
        return result
    }
    fileprivate func validate() {
        if !countryIsValid {
            showAlert(target: self, message: "Invalid Country Code.")
        }else if phoneNumber == "" {
            showAlert(target: self, message: "Input your Phone Number.")
        }else if !phoneNumberIsValid {
            showAlert(target: self, message: "Invalid Phone Number.")
        }else{
        }
    }
    /*
     // MARK: - customButton protocal functions
     */
    func onClickNext() {
        validate()
    }
    
    @IBAction func onClickContinue(_ sender: Any) {
        validate()
    }
    @IBAction func backClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
   
}
