//
//  familyMembersTableViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/3/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class familyMembersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func onAddNewMemberButtonClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "editProfileViewController") as? editProfileViewController {
            if let navigator = self.navigationController {
                //viewController.childName = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    var childs:[familyMember] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        user.getFamilyMembers {
            for key in user.familyMembers{
                if key.type == "child" {
                    self.childs.append(key)
                }
            }
            self.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func viewDidLayoutSubviews() {
        self.btnAdd.layer.cornerRadius = btnAdd.frame.height / 2
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return childs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! nameOfFamilyMemberTableViewCell
        cell.nameLabel.text = childs[indexPath.row].name
        cell.detailButton.tag = indexPath.row
        cell.detailButton.addTarget(self, action: #selector(selectDetail(sender:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "header")
        let border = UIView(frame: CGRect(x: 0, y: 49, width: self.view.bounds.width, height: 1))
        border.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        header?.addSubview(border)
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        //selectedCell.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "memberProfileViewController") as? memberProfileViewController {
            if let navigator = self.navigationController {
                viewController.child_id = childs[indexPath.row].uid
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func selectDetail(sender: UIButton){
        let buttonTag = sender.tag
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "memberProfileViewController") as? memberProfileViewController {
            if let navigator = self.navigationController {
                //let currCell = self.tableView.cellForRow(at: IndexPath(row: buttonTag, section: 0)) as! nameOfFamilyMemberTableViewCell
                viewController.child_id = childs[buttonTag].uid
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }

}
