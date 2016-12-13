//
//  WorkPackageWatchersVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 11/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

class WorkPackageWatchersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonAddWatcher: UIButton!
    
    var watchers: [OpUser] = []
    var workPackage: WorkPackage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        buttonAddWatcher.backgroundColor = Colors.lightAzureOP.getUIColor()
        buttonAddWatcher.tintColor = UIColor.white
        
        self.title = "Watchers"
        tableView.delegate = self
        tableView.dataSource = self
        if let wp = workPackage {
            if let watchHref = wp.watchHref {
                getWatchers(href: watchHref)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PresentAddWatcher" {
            let vc = segue.destination as? AddWatcherVC
            vc?.workPackage = self.workPackage
        }
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 1
        if watchers.count == 0 {
            numOfSections = 0
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "This workpackage has no watchers"
            noDataLabel.textColor = Colors.darkAzureOP.getUIColor()
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.separatorStyle = .none
            self.tableView.backgroundView = noDataLabel
        }  else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchers.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkPackageWatchersTVC") as! WorkPackageWatchersTVC!
        cell?.selectionStyle = .none
        let watcher = watchers[(indexPath as NSIndexPath).row] as OpUser
        cell?.textLabel?.text = watcher.name
        return cell!;
    }
    
    // Override to support editing the table view.
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.tableView.setEditing(editing, animated: animated)
//        self.addFilterButton.isEnabled = false
//        if editing == false {
//            self.addFilterButton.isEnabled = true
//            tableView.reloadData()
//        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "DELETE", handler: {
            action, index in
            
            LoadingUIView.show()
            let watcher = self.watchers[indexPath.row]
            
            OpenProjectAPI.sharedInstance.removeWorkPackageWatcher(watcherId: watcher.id, workPackageId: (self.workPackage?.id)!, onCompletion: {(responseObject:JSON, error:NSError?) in
                if let issue = error {
                    self.showRequestErrorAlert(error: issue)
                    LoadingUIView.hide()
                } else {
                    print(responseObject)
                    LoadingUIView.hide()
                    if let errors = ResponseValidationError.getFormErrors(json: responseObject) {
                        LoadingUIView.hide()
                        print("\(Date()) Watcher could not be removed")
                        self.showResponseErrorAlert(errors: errors)
                    } else {
                        print("\(Date()) Watcher has been removed on server")
                        print("\(Date()) Removing watcher localy")
                        OpUser.deleteUser(user: self.watchers[indexPath.row])
                        self.watchers.remove(at: indexPath.row)
                        //in case removing last row - deleting the whole section - otherwise it crashes
                        if self.watchers.count == 0 {
                            tableView.deleteSections([indexPath.section], with: .fade)
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                            self.setEditing(false, animated: true)
                        } else {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            })
        })
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    //My methods
    func getWatchers(href: String) {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getWatchers(href: href, onCompletion: {(responseObject: JSON, error:NSError?) in
            if let issue = error {
                print(issue.description)
                self.showRequestErrorAlert(error: issue)
                LoadingUIView.hide()
            } else {
                OpUser.buildOpUsers(json: responseObject)
                self.watchers = OpUser.mr_findAllSorted(by: "name", ascending: true) as! [OpUser]
                self.navigationItem.rightBarButtonItem?.isEnabled = self.watchers.count > 0
                LoadingUIView.hide()
                self.tableView.reloadData()
            }
        })
    }
    
    private func showRequestErrorAlert(error: Error) {
        let alertController = ErrorAlerts.getAlertController(error: error, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showResponseErrorAlert(errors: [ResponseValidationError]) {
        let alertController = ErrorAlerts.getAlertController(errors: errors, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
}
