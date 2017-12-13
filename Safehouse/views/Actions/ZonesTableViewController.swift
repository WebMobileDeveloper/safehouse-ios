//
//  ZonesTableViewController.swift
//  Safehouse
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class ZonesTableViewController: UITableViewController {
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func addNewZoneClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "addZoneViewController") as? addZoneViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        user.getZones {
            self.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return user.zones.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < user.zones.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "zoneCell") as! zoneTableViewCell
            cell.lblZoneName.text = user.zones[indexPath.row].name != "" ? user.zones[indexPath.row].name : "Unnamed Zone"
            cell.zoneDetailButton.tag = indexPath.row
            cell.zoneDetailButton.addTarget(self, action: #selector(onzoneDetailButtonClick(_:)), for: .touchUpInside)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addZoneCell")
            cell?.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            return cell!
        }
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
        if indexPath.row == user.zones.count{
            return 100
        }
        return 48
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "zoneDetailViewController") as? zoneDetailViewController {
            viewController.zone = user.zones[indexPath.row]
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        //selectedCell.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    func onzoneDetailButtonClick(_ sender: UIButton) {
        if let viewController = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "zoneDetailViewController") as? zoneDetailViewController {
            viewController.zone = user.zones[sender.tag]
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}
