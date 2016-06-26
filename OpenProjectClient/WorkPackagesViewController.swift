//
//  CenterViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: ContainerViewControllerDelegate?
    var project: Project?
    var workpackages: [WorkPackage] = []

    @IBOutlet weak var tableViewWorkPackages: UITableView!
    
    @IBOutlet weak var addWPButton: UIBarButtonItem!
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Work Packages"
        
        setNeedsStatusBarAppearanceUpdate()
        
        //disable filter and add button in case project is not selected
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let instanceId = defaults.valueForKey("InstanceId") as? String {
            if let projectId = defaults.valueForKey("ProjectId") as? NSNumber {
                getWorkPackages(projectId, instanceId: instanceId)
            }
        } else {
            ///show alert notifying that there is no instance selected. consider showing this alert just once after application start
            let alertController = UIAlertController(title: "ERROR", message: "No instance is defined\nGo to settings and setup new instance", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                switch (action.style) {
                case .Default:
                    self.dismissViewControllerAnimated(true, completion: nil)
                    break
                default:
                    break
                }
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        setButtons()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    @IBAction func menuTapped(sender: AnyObject) {
        delegate?.toggleLeftPanel!()
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workpackages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkpackageCell") as! WorkPackagesTableViewCell!
        let wp = workpackages[indexPath.row]
        cell.labelSubject.lineBreakMode = .ByWordWrapping
        cell.labelSubject.numberOfLines = 2
        cell.labelSubject.text = wp.subject
        cell.labelDescription.font = UIFont.italicSystemFontOfSize(12)
        cell.labelDescription.text = "Status: \(wp.statusTitle!), Priority: \(wp.priorityTitle!), Type: \(wp.typeTitle!)"
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = UIStoryboard.wpDetailViewController()
        vc?.workpackage = workpackages[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
        
        tableViewWorkPackages.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    //button add
    
    @IBAction func buttonAddTapped(sender: AnyObject) {
        let vc = UIStoryboard.wpEditViewController()
        let navCon = UINavigationController(rootViewController: vc!)
        self.presentViewController(navCon, animated: true, completion: nil)
    }

    //filters button
    @IBAction func filterButtonTapped(sender: AnyObject) {
        let vc = UIStoryboard.filtersViewController()
        delegate?.collapseSidePanels!()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    func setButtons() {
        
        if let _ = defaults.valueForKey("ProjectId") as? NSNumber {
            filterButton.enabled = true
            addWPButton.enabled = true
        } else {
            filterButton.enabled = false
            addWPButton.enabled = false
        }
    }
    
    func getWorkPackages(projectId: NSNumber, instanceId: String) {
        OpenProjectAPI.sharedInstance.getWorkPackagesByProjectId(projectId, instanceId: instanceId, onCompletion: {(responseObject:[WorkPackage]?, error:NSError?) in
            if let issue = error {
                print(issue.description)
            } else {
                if let _ = responseObject {
                    self.workpackages = WorkPackage.MR_findAllSortedBy("id", ascending: false) as! [WorkPackage]
                    self.tableViewWorkPackages.reloadData()
                }
            }
        })
    }
}
