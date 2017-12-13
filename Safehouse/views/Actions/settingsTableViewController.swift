//
//  settingsTableViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/2/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class settingsTableViewController: UITableViewController {

    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func onEditProfileButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "editProfileViewController") as? editProfileViewController {
            if let navigator = self.navigationController {
                //viewController.childName = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    @IBAction func onFamilyMembersButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "familyMembersTableViewController") as? familyMembersTableViewController {
            if let navigator = self.navigationController {
                //viewController.childName = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifiers = ["profile","zones","familyMembers","logout"]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.row])
        return cell!
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "header")
        let border = UIView(frame: CGRect(x: 0, y: 49, width: self.view.bounds.width, height: 1))
        border.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        header?.addSubview(border)
        return header
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 60
        }else{
            return 50
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:  //profile
                if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "editProfileViewController") as? editProfileViewController {
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 1:
                if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "ZonesTableViewController") as? ZonesTableViewController {
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
                return
            case 2:
                if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "familyMembersTableViewController") as? familyMembersTableViewController {
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            default:
                user.signOut {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                return
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        //selectedCell.backgroundColor = UIColor(white: 1, alpha: 0)
    }
}
