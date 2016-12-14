//
//  AddWatcherVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 12/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol AddWatcherVCDelegate {
    func addingWatchersFinished()
}

class AddWatcherVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var buttonAddWatcher: UIButton!
    
    @IBOutlet weak var buttonCancel: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var workPackage: WorkPackage?
    var delegate: AddWatcherVCDelegate?
    
    var availableWatchers: [OpUser] = []
    var selectedWatchers: [OpUser] = []
    var selectedWatchersIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        self.title = "Add watcher"
        
        buttonAddWatcher.backgroundColor = Colors.darkAzureOP.getUIColor()
        buttonAddWatcher.tintColor = UIColor.white
        buttonAddWatcher.isEnabled = false
        
        buttonCancel.backgroundColor = Colors.lightAzureOP.getUIColor()
        buttonCancel.tintColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        
        getAvailableWatchers()
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAddWatcherTapped(_ sender: Any) {
        LoadingUIView.show()
        addWatcher()
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getAvailableWatchers() {
        if let wpId = self.workPackage?.id {
            LoadingUIView.show()
            OpenProjectAPI.sharedInstance.getAvailableWatchers(workPackageId: wpId, testRightsOnly: false, onCompletion: {(responseObject:Bool, error:NSError?) in
                if let issue = error {
                    print(issue.description)
                    self.showRequestErrorAlert(error: issue)
                    LoadingUIView.hide()
                } else {
                    LoadingUIView.hide()
                    if let users = OpUser.getAllUsers() {
                        self.availableWatchers = users
                        self.buttonAddWatcher.isHidden = self.availableWatchers.count > 0 ? false : true
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func addWatcher() {
        
        guard selectedWatchers.count > 0 else {
            return
        }
        
        let watcher = selectedWatchers[self.selectedWatchersIndex] as OpUser
        guard let wpId = self.workPackage?.id else {
            LoadingUIView.hide()
            return
        }
        OpenProjectAPI.sharedInstance.addWatcher(to: wpId, payload: watcher.payload, onCompletion: {(responseObject:JSON, error:NSError?) in
            if let issue = error {
                print(issue.description)
                self.showRequestErrorAlert(error: issue)
                LoadingUIView.hide()
            } else {
                self.selectedWatchersIndex = self.selectedWatchersIndex + 1
                if self.selectedWatchersIndex < self.selectedWatchers.count {
                    self.addWatcher()
                } else {
                    LoadingUIView.hide()
                    self.delegate?.addingWatchersFinished()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 1
        if availableWatchers.count == 0 {
            numOfSections = 0
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "No watchers are available"
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
        return availableWatchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddWatcherTVC") as! AddWatcherTVC!
        cell?.selectionStyle = .none
        let watcher = availableWatchers[(indexPath as NSIndexPath).row] as OpUser
        if let name = watcher.name {
            cell?.textLabel?.text = name
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedWatchers.append(availableWatchers[indexPath.row])
        self.buttonAddWatcher.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedWatcher = availableWatchers[indexPath.row]
        if let i = selectedWatchers.index(where: { $0.id == selectedWatcher.id }) {
            selectedWatchers.remove(at: i)
        }
        self.buttonAddWatcher.isEnabled = selectedWatchers.count > 0
    }
    
    /*
    private func showResponseErrorAlert(errors: [ResponseValidationError]) {
        let alertController = ErrorAlerts.getAlertController(errors: errors, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
    */
    private func showRequestErrorAlert(error: Error) {
        let alertController = ErrorAlerts.getAlertController(error: error, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
}
