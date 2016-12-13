//
//  AddWatcherVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 12/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class AddWatcherVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var buttonAddWatcher: UIButton!
    
    @IBOutlet weak var buttonCancel: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var workPackage: WorkPackage?
    
    var availableWatchers: [OpUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        buttonAddWatcher.backgroundColor = Colors.darkAzureOP.getUIColor()
        buttonAddWatcher.tintColor = UIColor.white
        
        buttonCancel.backgroundColor = Colors.lightAzureOP.getUIColor()
        buttonCancel.tintColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getWatchers()
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAddWatcherTapped(_ sender: Any) {
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
    
    func getWatchers() {
        if let wpId = self.workPackage?.id {
            LoadingUIView.show()
            OpenProjectAPI.sharedInstance.getAvailableWatchers(workPackageId: wpId, onCompletion: {(responseObject:Bool, error:NSError?) in
                if let issue = error {
                    print(issue.description)
                    self.showRequestErrorAlert(error: issue)
                    LoadingUIView.hide()
                } else {
                    LoadingUIView.hide()
                    if let users = OpUser.getAllUsers() {
                        self.availableWatchers = users
                        self.buttonAddWatcher.isEnabled = self.availableWatchers.count > 0 ? true : false
                        self.tableView.reloadData()
                    }
                }
            })
        }
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
