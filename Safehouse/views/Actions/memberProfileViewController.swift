//
//  memberProfileViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/3/17.
//  Copyright © 2017 Delicious. All rights reserved.
//
//*************************
//*******************
//****************
import UIKit

class memberProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
    
    var child_id:String = ""
    
    var profileImage:UIImage = UIImage()
    var imageChanged = false
    
    let noti_labels = ["Low Battery", "Speeding", "Device Off/On", "App Installed", "Entering Safe Zone", "Leaving Safe Zone", "Entering Unsafe Zone", "Leaving Unsafe Zone"]
    let noti_keys:[String] = ["low_battery", "speeding", "device_on_off", "app_installed", "enter_safe_zone", "leave_safe_zone", "enter_unsafe_zone", "leave_unsafe_zone"]
    var noti_values:[String:Int] = ["low_battery":0, "speeding":0, "device_on_off":0, "app_installed":0, "enter_safe_zone":0, "leave_safe_zone":0, "enter_unsafe_zone":0, "leave_unsafe_zone":0]
    
    let field_labels = ["","Full name", "Birthday", "Gender", "Height", "Weight", "Eye Color", "Hair Color"]
    let field_keys:[String] = ["photo_url", "full_name", "birthdate", "gender", "height", "weight", "eye_color", "hair_color"]
    let field_placeholders:[String] = ["photo_url", "Jane Doe", "YYYY/MM/DD", "Male or Female", "6\'6\"", "150 lbs", "Black", "Black"]
    var field_values:[String:String] = ["photo_url":"","full_name":"", "birthdate":"", "gender":"", "height":"", "weight":"", "eye_color":"", "hair_color":""]
    var key_phrases:[String] = []
    
    var activeField:UITextField?
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        registerForKeyboardNotifications()
        user.child_id = child_id
        user.getChildInfo {
            self.lblName.text = user.child.name
            if user.child.photo_url != ""{
                let url = URL(string:user.child.photo_url)
                let data = try? Data(contentsOf: url!)
                if data != nil{
                    self.profileImage = UIImage(data: data!)!
                }else{
                    self.profileImage = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
                }
            }else{
                self.profileImage = #imageLiteral(resourceName: "editProfilePhotoGreyIcon")
            }
            
            for key in self.field_keys{
                self.field_values[key] = user.child.value(forKey: key) as? String
            }
            self.tableView.reloadData()
        }
        user.getChildSetting {
            for key in self.noti_keys{
                self.noti_values[key] = user.childSetting.notifications[key]
            }
            self.key_phrases = user.childSetting.key_phrases
            self.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /*-----------------keyboard show only keyboard cover text field---------------------
     */
 
     func registerForKeyboardNotifications(){
     //Adding notifies on keyboard appearing
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
     }
     
     func deregisterFromKeyboardNotifications(){
     //Removing notifies on keyboard appearing
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
     }
     
     func keyboardWasShown(notification: NSNotification){
        var keyboardHeight:CGFloat = 0.0
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= keyboardHeight
        
        let pointInTable = activeField!.superview!.convert(activeField!.frame.origin, to: tableView)
        let rectInTable = activeField!.superview!.convert(activeField!.frame, to: tableView)
        
        if !aRect.contains(pointInTable) {
            self.tableView.scrollRectToVisible(rectInTable, animated: true)
        }
     }
     
     func keyboardWillBeHidden(notification: NSNotification){
         let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
         self.tableView.contentInset = contentInsets
         self.tableView.scrollIndicatorInsets = contentInsets
         //self.view.endEditing(true)
     }
     
     func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
     }
     
     func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
        if textField.tag < 8 {
            field_values[field_keys[textField.tag]] = textField.text!
        }
     }
 
    /*--------------------------------------------------------*/
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 9
        case 1:
            return 9
        case 2:
            return user.childSetting.key_phrases.count + 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                switch indexPath.row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! editphotoTableViewCell
                        cell.profileImage.image = profileImage
                        cell.editPhotoButton.tag = indexPath.row
                        cell.editPhotoButton.addTarget(self, action: #selector(addPhotoBtnTapped(sender:)), for: .touchUpInside)
                        return cell
                    case 1...7:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "profileItemCell") as! profileItemTableViewCell
                        cell.itemLabel.text = field_labels[indexPath.row]
                        cell.itemTextField.text = field_values[field_keys[indexPath.row]]
                        cell.itemTextField.placeholder = field_placeholders[indexPath.row]
                        cell.itemTextField.tag = indexPath.row
                        if indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5 {
                            cell.itemTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
                        }
                        cell.itemTextField.delegate = self
                        return cell
                    case 8:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "shareProfileCell") as! shareProfileTableViewCell
                        cell.shareProfileButton.addTarget(self, action: #selector(shareProfileButtonTapped(sender:)), for: .touchUpInside)
                        return cell
                    default:
                        return UITableViewCell()
                }
            case 1:
                if indexPath.row < 8{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! notificationTableViewCell
                    cell.notificationTitleLabel.text = noti_labels[indexPath.row]
                    cell.notificationSwich.setOn((noti_values[noti_keys[indexPath.row]] != 0) as Bool, animated: false)
                    cell.notificationSwich.tag = 100 + indexPath.row
                    cell.notificationSwich.addTarget(self, action: #selector(onSwitchValueChanged(sender:)), for: .valueChanged)
                    cell.notificationSwich.transform = CGAffineTransform(scaleX: 1, y: 0.9)
                    return cell
                }else{
                    let cell  = tableView.dequeueReusableCell(withIdentifier: "header3") as! keyPhraseHeaderTableViewCell
                    //let header1:keyPhraseHeaderTableViewCell = header as! keyPhraseHeaderTableViewCell
                    cell.keyTextField.delegate = self
                    cell.phraseAddButton.addTarget(self, action: #selector(onAddPhrase(sender:)), for: .touchUpInside)
                    return cell
                }
            case 2:
                if indexPath.row < key_phrases.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "phraseCell") as! phraseTableViewCell
                    cell.phraseLabel.text = key_phrases[indexPath.row]
                    cell.deleteButton.tag = 200 + indexPath.row
                    cell.deleteButton.addTarget(self, action: #selector(onDeletePhrase(sender:)), for: .touchUpInside)
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "removeMemberCell") as! removeMemberTableViewCell
                    cell.removeMemberButton.addTarget(self, action:#selector(onRemoveMemberTapped(sender:)), for: .touchUpInside)
                    return cell
                }
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header:UITableViewCell
        switch section {
            case 0:
                header = tableView.dequeueReusableCell(withIdentifier: "header1")!
            case 1:
                header = tableView.dequeueReusableCell(withIdentifier: "header2")!
            default:
                header = UITableViewCell()
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2{
            return 0
        }else{
            return 65
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 &&  indexPath.row == 0 {
            return 60
        } else if indexPath.section == 1 && indexPath.row == 8 {
            return 130
        } else if indexPath.section == 2 && indexPath.row == user.childSetting.key_phrases.count {
            return 100
        } else {
            return 50
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        //selectedCell.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    
   
    
    
    
    /*  Mark: ImagePickerControllerdelegate functions
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! editphotoTableViewCell
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            cell.profileImage.image = chosenImage.resizeAndCompress(newWidth: PROFILE_IMAGE_WIDTH, maxSize: MAX_UPLOAD_IMAGE_SIZE)
            profileImage = cell.profileImage.image!
            print("------image changed")
        }
        imageChanged = true
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - button events
    
    /*  // share button tapped  */
    func shareProfileButtonTapped(sender:UIButton)  {
        let choiceAlert = UIAlertController(title: "Confirm", message: "Are you sure save and share this profile?", preferredStyle: UIAlertControllerStyle.alert)
        
        choiceAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if self.imageChanged == true {
                user.updateUserImage(newImage: self.profileImage ,uid:user.child_id, completion: { (photo_url) in
                    self.field_values["photo_url"] = photo_url
                    user.updateChildData(values: self.field_values, completion: {
                        showAlert(target: self, message: "Child data has been changed and shared successfully!", title: "Success")
                    })
                })
            }else{
                user.updateUserImage(newImage: self.profileImage ,uid:user.child_id, completion: { (photo_url) in
                    user.updateChildData(values: self.field_values, completion: {
                        showAlert(target: self, message: "Child data has been changed and shared successfully!", title: "Success")
                    })
                })
            }
            
        }))
        
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        self.present(choiceAlert, animated: true, completion: nil)
        
        
    }
    func onSwitchValueChanged(sender:UISwitch) {
        if sender.isOn{
            noti_values[noti_keys[sender.tag - 100]] = 1
            user.updateChildNotificationSetting(values: [noti_keys[sender.tag - 100]:1])
        }else{
            noti_values[noti_keys[sender.tag - 100]] = 0
            user.updateChildNotificationSetting(values: [noti_keys[sender.tag - 100]:0])
        }
    }
    
    func onDeletePhrase(sender:UIButton) {
        let choiceAlert = UIAlertController(title: "Confirm", message: "Are you sure want to delete this word(phrase)?", preferredStyle: UIAlertControllerStyle.alert)
        choiceAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.key_phrases.remove(at: sender.tag - 200)
            user.updateChildPhrasesSetting(values: self.key_phrases)
        }))
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        self.present(choiceAlert, animated: true, completion: nil)
    }
    func onAddPhrase(sender:UIButton) {
        let indexPath = IndexPath(row: 8, section: 1)
        let cell = tableView.cellForRow(at: indexPath) as! keyPhraseHeaderTableViewCell
        if cell.keyTextField.text?.count == 0{
            showAlert(target: self, message: "Please input your word or phrase")
        }else{
            key_phrases.append(cell.keyTextField.text!)
            cell.keyTextField.text = ""
            user.updateChildPhrasesSetting(values: key_phrases)
        }
    }

    func onRemoveMemberTapped(sender:UIButton) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "confirmRemoveMemberViewController") as? confirmRemoveMemberViewController {
            //viewController.name = name
            self.present(viewController, animated:true, completion:nil)
        }
    }
    /*             // - Show Image Picker             */
    func addPhotoBtnTapped(sender: UIButton) {
        showChoiceAlert(target: self)        
    }
    
    
}







