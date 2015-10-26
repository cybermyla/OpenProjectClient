//
//  SettingsViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 18/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddEditInstanceVCDelegate {

    var settings: Setting?
    var tableHeight: CGFloat?
    
    @IBOutlet weak var addInstanceButton: UIButton!
    @IBOutlet weak var tableViewInstances: UITableView!
    @IBOutlet weak var instanceTableViewHeightCon: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Colors.PaleOP.getUIColor()
        settings = SettingsManager.getSettings()
        
        addInstanceButton.backgroundColor = Colors.LightAzureOP.getUIColor()
        
        tableHeight = 50
        tableViewInstances.rowHeight = tableHeight!
        tableViewInstances.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        setInstanceTableViewSize(delete: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil);
    }

    @IBAction func saveTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    //tableview functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (settings!.instances.count > 0) {
            return settings!.instances.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstanceTableViewCell")! as UITableViewCell
        if (settings?.instances.count > 0) {
            cell.textLabel?.text = settings?.instances[indexPath.row].name
            cell.accessoryType = .Checkmark
        } else {
            cell.textLabel?.text = "No instance has been defined..."
            cell.selectionStyle = .None
        }
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if editing {
            addInstanceButton.enabled = false
        } else {
            addInstanceButton.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (settings?.instances.count > 0) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "EDIT", handler: {action ,index in
            let vc = UIStoryboard.addEditInstanceVC()
            vc?.instance = self.settings?.instances[indexPath.row]
            let navControler: UINavigationController = UINavigationController(rootViewController: vc!)
            vc?.delegate = self
            self.presentViewController(navControler, animated: true, completion: nil)
        })
        edit.backgroundColor = Colors.DarkAzureOP.getUIColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "DELETE", handler: {
            action, index in
            SettingsManager.deleteInstance((self.settings?.instances[indexPath.row])!)
            self.tableViewInstances.reloadData()
            self.setInstanceTableViewSize(delete: true)
        })
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
    
    func setInstanceTableViewSize(delete delete: Bool) {
        var height = CGFloat(0)
        if let s = settings {
            let count = s.instances.count
            if count > 0 {
                height = CGFloat(s.instances.count) * tableHeight!
            } else {
                height = tableHeight!
            }
        } else {
            height = tableHeight!
        }
        if (delete) {
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.instanceTableViewHeightCon.constant = height
            self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.instanceTableViewHeightCon.constant = height
        }
    }
    
    @IBAction func addInstanceTapped(sender: AnyObject) {
        let vc = UIStoryboard.addEditInstanceVC()
        vc?.delegate = self
        let navVC = UINavigationController(rootViewController: vc!)
        self.presentViewController(navVC, animated: true, completion: nil)
        
    }
    
    //addedit instance view delegate
    func instanceSaved() {
        self.tableViewInstances.reloadData()
    }

}
