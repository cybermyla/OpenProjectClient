//
//  SettingsViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 18/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsHaveChanged()
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddEditInstanceVCDelegate {

    var tableHeight: CGFloat?
    var allInstances: [Instance] = []
    
    @IBOutlet weak var addInstanceButton: UIButton!
    @IBOutlet weak var tableViewInstances: UITableView!
    @IBOutlet weak var instanceTableViewHeightCon: NSLayoutConstraint!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var selectedInstanceIndexPath: NSIndexPath?
    var newSelectedInstanceId: String?
    
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAllInstances()
        self.view.backgroundColor = Colors.PaleOP.getUIColor()
        
        addInstanceButton.backgroundColor = Colors.LightAzureOP.getUIColor()
        
        tableHeight = 50
        tableViewInstances.backgroundColor = UIColor.whiteColor()
        tableViewInstances.rowHeight = tableHeight!
        tableViewInstances.separatorStyle = .None
        
        //save button is disabled unless any change is performed
        saveButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        setAllowSelection()
        setInstanceTableViewSize(delete: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
   //     tableViewInstances.selectRowAtIndexPath(selectedInstanceIndexPath, animated: false, scrollPosition: .None)
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

    //button is enabled only when new instance id does not match old
    @IBAction func saveTapped(sender: AnyObject) {
        defaults.setValue(newSelectedInstanceId, forKey: "InstanceId")
        delegate?.settingsHaveChanged()
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
        if (allInstances.count > 0) {
            return allInstances.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (allInstances.count > 0 && indexPath == selectedInstanceIndexPath) {
            tableViewInstances.selectRowAtIndexPath(selectedInstanceIndexPath, animated: false, scrollPosition: .None)
        } else if (allInstances.count == 0) {
            tableViewInstances.allowsSelection = false
        } else {
            tableViewInstances.allowsSelection = true
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstanceTableViewCell")! as! InstanceTableViewCell
        
        if (allInstances.count > 0) {
            let instance = allInstances[indexPath.row]
            cell.textLabel?.text = instance.instanceName
            cell.detailTextLabel?.enabled = true
            cell.detailTextLabel?.text = instance.address
            
            if let newSelectedInstanceIdUn = newSelectedInstanceId {
                if (newSelectedInstanceIdUn == instance.id!) {
                    selectedInstanceIndexPath = indexPath
                }
                
            } else if let currentInstanceId = defaults.valueForKey("InstanceId") as? String {
                if (currentInstanceId == instance.id!) {
                    selectedInstanceIndexPath = indexPath
                }
            }
        } else {
            cell.textLabel?.text = "No instance has been defined..."
            cell.detailTextLabel?.text = ""
            cell.selectionStyle = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if allInstances.count > 0 {
            newSelectedInstanceId = allInstances[indexPath.row].id
            if let currentInstanceId = defaults.valueForKey("InstanceId") as! String! {
                if (currentInstanceId == newSelectedInstanceId) {
                    saveButton.enabled = false
                } else {
                    saveButton.enabled = true
                }
            } else {
                saveButton.enabled = true
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if editing {
            addInstanceButton.enabled = false
        } else {
            addInstanceButton.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (allInstances.count > 0) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "EDIT", handler: {action ,index in
            let vc = UIStoryboard.addEditInstanceVC()
            
            let instance = self.allInstances[indexPath.row]
            vc?.currentInstanceAddress = instance.address
            vc?.currentInstanceApiKey = instance.apikey
            
            let navControler: UINavigationController = UINavigationController(rootViewController: vc!)
            vc?.delegate = self
            self.presentViewController(navControler, animated: true, completion: nil)
            tableView.editing = false
        })
        edit.backgroundColor = Colors.DarkAzureOP.getUIColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "DELETE", handler: {
            action, index in
            
            //if deleting new selected instance - change
            let deletedInstance = self.allInstances[indexPath.row]
            if (self.newSelectedInstanceId == deletedInstance.id) {
                self.newSelectedInstanceId = nil
            }
            
            if let currentInstanceId = self.defaults.valueForKey("InstanceId") {
                if ((currentInstanceId as! String) == deletedInstance.id) {
                    self.defaults.setValue(nil, forKey: "InstanceId")
                }
            }
            
            self.allInstances.removeAtIndex(indexPath.row).MR_deleteEntity()
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            
            self.tableViewInstances.reloadData()
            self.setInstanceTableViewSize(delete: true)
        })
        delete.backgroundColor = UIColor.redColor()
        return [delete, edit]
    }
    
    func setInstanceTableViewSize(delete delete: Bool) {
        var height = CGFloat(0)
        if allInstances.count > 0 {
            height = CGFloat(allInstances.count) * tableHeight!
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
    
    func getAllInstances() {
        allInstances = Instance.MR_findAllSortedBy("instanceName", ascending: true) as! [Instance]
    }
    
    //addedit instance view delegate
    func instanceSaved(instanceId: String) {
        getAllInstances()
        setAllowSelection()
        newSelectedInstanceId = instanceId
        self.tableViewInstances.reloadData()
        saveButton.enabled = true
    }
    
    func setAllowSelection() {
        if (allInstances.count > 0) {
            tableViewInstances.allowsSelection = true
        } else {
            tableViewInstances.allowsSelection = false
        }
    }
}
