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
    func menuItemTapped(_ item: MenuItem)
    func projectSelected(_ project: Project)
}

enum MenuItem: Int {
    case workPackages
    case activities
    
    func viewController() -> UIViewController {
        switch (self) {
        case .workPackages: return {
            let vc = UIStoryboard.workPackagesViewController()
            return vc!
            }()
        case .activities: return {
            let vc = UIStoryboard.activitiesViewController()
            return vc!
            }()        }
    }
    
    func name() -> String {
        switch (self) {
        case .workPackages: return "WorkPackages"
        case .activities: return "Activities"
        }
    }
    
    func id() -> Int {
        switch (self) {
        case .workPackages: return 0
        case .activities: return 1
        //default: return -1
        }
    }
    
    static func menuItemById(_ id: Int) -> MenuItem {
        switch (id) {
        case 0: return .workPackages
        case 1: return .activities
        default: return .workPackages
        }
    }
    
    static func nameById(_ itemId: Int) -> String {
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
    
    var items: [MenuItem] = [.workPackages, .activities]
    var projects: [Project] = []
    
    var projectsTableViewHeight:CGFloat = 0
    let maxProjectsTableViewNr = 8
    
    let defaults = UserDefaults.standard
    
    var instanceSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            instanceSelected = true
            getProjects(instanceId)
        }
        
        menuTableView.separatorStyle = .none
        projectsTableView.separatorStyle = .none
        projectsTableView.backgroundColor = Colors.paleOP.getUIColor()
        
        //getProjects()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        projectsViewConHeight.constant = 0
        if (projects.count > 0) {
            let projectsRowHeight = projectsTableView.rectForRow(at: IndexPath(row: 0, section: 0)).height
            if projects.count <= maxProjectsTableViewNr {
                projectsTableViewHeight = CGFloat(projects.count) * projectsRowHeight
            } else {
                projectsTableViewHeight = CGFloat(maxProjectsTableViewNr) * projectsRowHeight
            }
        }
        
        //highlight selected menuitem
        highlightSelectedMenuitem()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //disable / enable menuitems and buttons - instance is not selected or defined
        if instanceSelected {
            //instance has been selected
            projectButton.isEnabled = true
        } else {
            //disable buttons and menus
            projectButton.isEnabled = false
        }
                
        if let projectId = defaults.value(forKey: "ProjectId") as? NSNumber {
            //will have to get data from Core data
            let project = Project.mr_findFirst(byAttribute: "id", withValue: projectId)
            projectButton.setTitle("\(project?.name!)", for: UIControlState())
        } else {
            projectButton.setTitle("Select Project", for: UIControlState())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resizeProjectsView(_ sender: AnyObject) {
        projectsTableView.reloadData()
        let height:CGFloat = projectsTableViewHeight
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
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
    
    @IBAction func buttonSettingsTapped(_ sender: AnyObject) {
        let vc = UIStoryboard.settingsViewController()
        vc?.delegate = self
        let navController = UINavigationController(rootViewController: vc!)
        self.present(navController, animated: true, completion: nil)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return items.count
        } else if tableView == projectsTableView {
            return projects.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (tableView) {
        case menuTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as UITableViewCell!
            let item = items[(indexPath as NSIndexPath).row];
            cell?.textLabel?.text = item.name()
            
            //check if instance selected
            if (instanceSelected) {
                cell?.textLabel?.textColor = UIColor.white
                if let menuId = defaults.value(forKey: "MenuId") as? Int {
                    if (item.name() == MenuItem.nameById(menuId)) {
                        cell?.backgroundColor = Colors.darkAzureOP.getUIColor()
                    }
                }
            } else {
            //disable cell selection if instance not selected
                cell?.textLabel?.textColor = UIColor.lightGray
                cell?.selectionStyle = .none
            }
            
            return cell!
        case projectsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as UITableViewCell!
            let project = projects[(indexPath as NSIndexPath).row]
            cell?.textLabel?.text = project.name
            cell?.textLabel?.textColor = Colors.darkAzureOP.getUIColor()
            return cell!
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (instanceSelected) {
            switch (tableView) {
            case menuTableView:
                delegate?.menuItemTapped(MenuItem(rawValue: (indexPath as NSIndexPath).row)!)
                break
            case projectsTableView:
                let p = projects[(indexPath as NSIndexPath).row] as Project
                defaults.set(Int(p.id!), forKey: "ProjectId")
                delegate?.projectSelected(projects[(indexPath as NSIndexPath).row])
                break
            default:
                break
            }
        }
    }
    
    func highlightSelectedMenuitem() {
        if let menuId = defaults.value(forKey: "MenuId") as? Int {
        switch (MenuItem.nameById(menuId)) {
        case "WorkPackages":
            menuTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            break
        case "Activities":
            menuTableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
            break
        default:
            break
        }
        }
    }
    
    //SettingsViewController delegate implementation
    func settingsHaveChanged() {
        
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            getRemoteProjects(instanceId)
            projects = Project.mr_findAll() as! [Project]
        }
    }
    
    func getProjects(_ instanceId: String) {
        
        self.projects = Project.mr_findAll() as! [Project]
        
        if projects.count > 0 {
            self.projectsTableView.reloadData()
        }
        else
        {
            getRemoteProjects(instanceId)
        }
    }
    
    func getRemoteProjects(_ instanceId: String) {
        OpenProjectAPI.sharedInstance.getProjects(instanceId, onCompletion: {(responseObject:[Project]?, error:NSError?) in
            if let issue = error {
                print(issue.description)
            } else {
                if let projects = responseObject {
                    self.projects = projects
                    self.projectsTableView.reloadData()
                }
            }
        })
    }
}
