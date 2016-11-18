//
//  SettingsViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 18/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsClosed()
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddEditInstanceVCDelegate {

    var tableHeight: CGFloat?
    var allInstances: [Instance] = []
    
    @IBOutlet weak var addInstanceButton: UIButton!
    @IBOutlet weak var tableViewInstances: UITableView!
    @IBOutlet weak var instanceTableViewHeightCon: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        allInstances = Instance.getAllInstances()
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        addInstanceButton.backgroundColor = Colors.lightAzureOP.getUIColor()
        addInstanceButton.tintColor = UIColor.white
        
        tableHeight = 50
        tableViewInstances.backgroundColor = UIColor.white
        tableViewInstances.rowHeight = tableHeight!
        tableViewInstances.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setAllowSelection()
        setInstanceTableViewSize(delete: false)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        delegate?.settingsClosed()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    //tableview functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (allInstances.count > 0) {
            return allInstances.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstanceTableViewCell")! as! InstanceTableViewCell
        
        if (allInstances.count > 0) {
            let instance = allInstances[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = instance.instanceName
            cell.detailTextLabel?.isEnabled = true
            cell.detailTextLabel?.text = instance.address
            cell.selectionStyle = .none
            if let instanceId = defaults.value(forKey: "InstanceId") as? String {
                if instanceId == instance.id {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        } else {
            cell.textLabel?.text = "No instance has been defined..."
            cell.detailTextLabel?.text = ""
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allInstances.count > 0 {
            let selectedInstanceId = allInstances[(indexPath as NSIndexPath).row].id
            defaults.setValue(selectedInstanceId, forKey: "InstanceId")
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            addInstanceButton.isEnabled = false
        } else {
            addInstanceButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (allInstances.count > 0) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "EDIT", handler: {action ,index in
            let vc = UIStoryboard.addEditInstanceVC()
            
            let instance = self.allInstances[(indexPath as NSIndexPath).row]
            vc?.currentInstanceAddress = instance.address
            vc?.currentInstanceApiKey = instance.apikey
            
            let navControler: UINavigationController = UINavigationController(rootViewController: vc!)
            vc?.delegate = self
            self.present(navControler, animated: true, completion: nil)
            tableView.isEditing = false
        })
        edit.backgroundColor = Colors.darkAzureOP.getUIColor()
        
        let delete = UITableViewRowAction(style: .normal, title: "DELETE", handler: {
            action, index in
            
            //if deleting new selected instance - change
            let deletedInstance = self.allInstances[(indexPath as NSIndexPath).row]
            
            if let instanceId = self.defaults.value(forKey: "InstanceId") as? String {
                if deletedInstance.id == instanceId {
                    self.defaults.setValue(nil, forKey: "InstanceId")
                }
            }
            
            self.allInstances.remove(at: (indexPath as NSIndexPath).row).mr_deleteEntity()
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            
            self.tableViewInstances.reloadData()
            self.setInstanceTableViewSize(delete: true)
        })
        delete.backgroundColor = UIColor.red
        return [delete, edit]
    }
    
    func setInstanceTableViewSize(delete: Bool) {
        var height = CGFloat(0)
        if allInstances.count > 0 {
            height = CGFloat(allInstances.count) * tableHeight!
        } else {
            height = tableHeight!
        }

        if (delete) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.instanceTableViewHeightCon.constant = height
            self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.instanceTableViewHeightCon.constant = height
        }
    }
    
    @IBAction func addInstanceTapped(_ sender: AnyObject) {
        let vc = UIStoryboard.addEditInstanceVC()
        vc?.delegate = self
        let navVC = UINavigationController(rootViewController: vc!)
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    //addedit instance view delegate
    func instanceSaved(_ instanceId: String) {
        allInstances = Instance.getAllInstances()
        setAllowSelection()
        self.tableViewInstances.reloadData()
    }
    
    func setAllowSelection() {
        if (allInstances.count > 0) {
            tableViewInstances.allowsSelection = true
        } else {
            tableViewInstances.allowsSelection = false
        }
    }
}
