//
//  WorkPackageWatchersVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 11/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackageWatchersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var watchers: [OpUser] = []
    var workPackage: WorkPackage?
    var watcherHrefs: [String] = []
    var watcherHrefsIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        if let wHref = workPackage?.watchHref {
            watcherHrefs = wHrefs
            getUserDetail()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 1
        if watchers.count == 0 {
            numOfSections = 0
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "No watchers are assigned"
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkPackageWatchersTVC") as! WorkPackageWatchersTVC!
        cell?.selectionStyle = .none
        let watcher = watchers[(indexPath as NSIndexPath).row] as OpUser
        cell?.textLabel?.text = watcher.name
        return cell!;
    }
    
    //My methods
    func getUserDetail() {
        if watcherHrefs.count > 0 {
            let href = watcherHrefs[self.watcherHrefsIndex]
            OpenProjectAPI.sharedInstance.getUser(href: href, onCompletion: {(responseObject:Bool, error:NSError?) in
                if let issue = error {
                    print(issue.description)
                    LoadingUIView.hide()
                } else {
                    self.watcherHrefsIndex = self.watcherHrefsIndex + 1
                    if self.watcherHrefsIndex < self.watcherHrefs.count {
                        self.getUserDetail()
                    } else {
                        self.watchers = OpUser.mr_findAllSorted(by: "name", ascending: true) as! [OpUser]
                        self.tableView.reloadData()
                        LoadingUIView.hide()
                    }
                }
            })
        } else {
            print("user hrefs count is 0")
        }
    }
    
    func getWatchers() {
        
    }
}
