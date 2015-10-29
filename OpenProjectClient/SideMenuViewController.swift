//
//  SidePanelViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol SideMenuViewControllerDelegate {
    func menuItemTapped(item: MenuItem)
    func projectSelected(project: Project)
}

enum MenuItem: Int {
    case WorkPackages
    case Activities
    
    func viewController() -> UIViewController {
        switch (self) {
        case WorkPackages: return {
            let vc = UIStoryboard.workPackagesViewController()
            return vc!
            }()
        case Activities: return {
            let vc = UIStoryboard.activitiesViewController()
            return vc!
            }()        }
    }
    
    func name() -> String {
        switch (self) {
        case .WorkPackages: return "WorkPackages"
        case .Activities: return "Activities"
        }
    }
    
    func id() -> Int {
        switch (self) {
        case .WorkPackages: return 0
        case .Activities: return 1
        //default: return -1
        }
    }
    
    static func menuItemById(id: Int) -> MenuItem {
        switch (id) {
        case 0: return .WorkPackages
        case 1: return .Activities
        default: return .WorkPackages
        }
    }
    
    static func nameById(itemId: Int) -> String {
        switch (itemId) {
            case 0: return "WorkPackages"
            case 1: return "Activities"
            default: return "Unknown"
        }
    }
}

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SettingsViewControllerDelegate {
    
    var delegate: SideMenuViewControllerDelegate?
    
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var projectButton: UIButton!
    @IBOutlet weak var projectsView: UIView!
    @IBOutlet weak var projectsTableView: UITableView!
    
    @IBOutlet weak var projectsViewConHeight: NSLayoutConstraint!
    
    var items: [MenuItem] = [.WorkPackages, .Activities]
    var projects: [Project] = []
    
    var projectsTableViewHeight:CGFloat = 0
    let maxProjectsTableViewNr = 8
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var instanceSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = defaults.valueForKey("InstanceId") as? String {
            instanceSelected = true
        }
        
        menuTableView.separatorStyle = .None
        projectsTableView.separatorStyle = .None
        projectsTableView.backgroundColor = Colors.PaleOP.getUIColor()
        
        getProjects()
    }
    
    override func viewDidAppear(animated: Bool) {
        projectsViewConHeight.constant = 0
        if (projects.count > 0) {
            let projectsRowHeight = projectsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).height
            if projects.count <= maxProjectsTableViewNr {
                projectsTableViewHeight = CGFloat(projects.count) * projectsRowHeight
            } else {
                projectsTableViewHeight = CGFloat(maxProjectsTableViewNr) * projectsRowHeight
            }
        }
        
        //highlight selected menuitem
        highlightSelectedMenuitem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //disable / enable menuitems and buttons - instance is not selected or defined
        if instanceSelected {
            //instance has been selected
            projectButton.enabled = true
        } else {
            //disable buttons and menus
            projectButton.enabled = false
        }
        
        
        projects = Project.MR_findAll() as! [Project]
        
        if let projectId = defaults.valueForKey("ProjectId") {
            //will have to get data from Core data
            projectButton.setTitle("Project \(projectId)", forState: .Normal)
        } else {
            projectButton.setTitle("Select Project", forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resizeProjectsView(sender: AnyObject) {
        projectsTableView.reloadData()
        let height:CGFloat = projectsTableViewHeight
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                if (self.projectsViewConHeight.constant == 0) {
                    self.projectsViewConHeight.constant = height
                } else {
                    self.projectsViewConHeight.constant = 0
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
/*
        if let indexPath = AppState.sharedInstance.projectIndexPath {
            self.projectsTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Middle)
        }
*/
    }
    
    @IBAction func buttonSettingsTapped(sender: AnyObject) {
        let vc = UIStoryboard.settingsViewController()
        vc?.delegate = self
        let navController = UINavigationController(rootViewController: vc!)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return items.count
        } else if tableView == projectsTableView {
            return projects.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (tableView) {
        case menuTableView:
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell") as UITableViewCell!
            let item = items[indexPath.row];
            cell.textLabel?.text = item.name()
            
            //check if instance selected
            if (instanceSelected) {
                cell.textLabel?.textColor = UIColor.whiteColor()
                if let menuId = defaults.valueForKey("MenuId") as? Int {
                    if (item.name() == MenuItem.nameById(menuId)) {
                        cell.backgroundColor = Colors.DarkAzureOP.getUIColor()
                    }
                }
            } else {
            //disable cell selection if instance not selected
                cell.textLabel?.textColor = UIColor.lightGrayColor()
                cell.selectionStyle = .None
            }
            
            return cell
        case projectsTableView:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell") as UITableViewCell!
            let project = projects[indexPath.row]
            cell.textLabel?.text = project.name
            cell.textLabel?.textColor = Colors.DarkAzureOP.getUIColor()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (instanceSelected) {
            switch (tableView) {
            case menuTableView:
                delegate?.menuItemTapped(MenuItem(rawValue: indexPath.row)!)
                break
            case projectsTableView:
                let p = projects[indexPath.row] as Project
                defaults.setInteger(Int(p.id!), forKey: "ProjectId")
                delegate?.projectSelected(projects[indexPath.row])
                break
            default:
                break
            }
        }
    }
    
    func highlightSelectedMenuitem() {
        if let menuId = defaults.valueForKey("MenuId") as? Int {
        switch (MenuItem.nameById(menuId)) {
        case "WorkPackages":
            menuTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
            break
        case "Activities":
            menuTableView.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: false, scrollPosition: .None)
            break
        default:
            break
        }
        }
    }
    
    //SettingsViewController delegate implementation
    func settingsHaveChanged() {
        projects = Project.MR_findAll() as! [Project]
    }
    
    ///
    ///Requests to the API
    ///
    func getProjects() {
        let projectsRequest = "https://community.openproject.org/api/v2/projects.json?key=9cfa5e3eea8f3537c50d30c2a0f6bb14a40f0217"
        Alamofire.request(Method.GET, projectsRequest)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            switch response.result {
            case .Success:
                    NSLog("Projects response validation successful")
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        //delete all projects from core data
                        Project.MR_truncateAll()
                        
                        for item in json["projects"].arrayValue {
                            let project = Project.MR_createEntity() as Project
                            
                            if let projectId:Int = item["id"].int{
                                project.id = NSNumber(integer: projectId)
                            }
                            if let responsibleId:Int = item["responsible_id"].int{
                                project.responsible_id = NSNumber(integer: responsibleId)
                            }
                            if let projectTypeId:Int = item["project_type_id"].int{
                                project.project_type_id = NSNumber(integer: projectTypeId)
                            }
                            if let identifier:String = item["identifier"].string {
                                project.identifier = identifier
                            }
                            if let parentId:Int = item["parent_id"].int {
                                project.parent_id = NSNumber(integer: parentId)
                            }
                            if let desc:String = item["description"].string {
                                project.desc = desc
                            }
                            if let name:String = item["name"].string {
                                project.name = name
                            }
                        }
                        NSLog("Project json has been parsed\(json)")
                        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                        
                        //just a test
                        self.projectsTableView.reloadData()
                    }
                break
            case .Failure(let error):
                    NSLog("Projects response validation failure - \(error)")
                break
            }
        }
    }
}
