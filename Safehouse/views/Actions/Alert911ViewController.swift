//
//  Alert911ViewController.swift
//  Safehouse
//
//  Created by Delicious on 9/29/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import MessageUI
class Alert911ViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBAction func btnText911Click(_ sender: Any) {
        if MFMessageComposeViewController.canSendText(){
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Enter a message";
            messageVC.recipients = ["911"]
            messageVC.messageComposeDelegate = self;

            self.present(messageVC, animated: false, completion: nil)
        }else{
            showAlert(target: self, message: "Your device can't send message.")
        }
    }
    @IBAction func btnCall911Click(_ sender: Any) {
        if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnCancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    
}
