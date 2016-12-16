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
    func projectSelected()
}

enum MenuItem: Int {
    case workPackages
    //case activities
    
    func viewController() -> UIViewController {
        switch (self) {
        case .workPackages: return {
            let vc = UIStoryboard.workPackagesViewController()
            return vc!
            }()
      //  case .activities: return {
      //      let vc = UIStoryboard.activitiesViewController()
      //      return vc!
      //      }()        
        }
    }
    
    func name() -> String {
        switch (self) {
        case .workPackages: return "WorkPackages"
        //case .activities: return "Activities"
        }
    }
    
    func id() -> Int {
        switch (self) {
        case .workPackages: return 0
        //case .activities: return 1
        //default: return -1
        }
    }
    
    static func menuItemById(_ id: Int) -> MenuItem {
        switch (id) {
        case 0: return .workPackages
        //case 1: return .activities
        default: return .workPackages
        }
    }
    
    static func nameById(_ itemId: Int) -> String {
        switch (itemId) {
            case 0: return "WorkPackages"
          //  case 1: return "Activities"
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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var constraintProjectButtonWidth: NSLayoutConstraint!
    
    var items: [MenuItem] = [.workPackages]
    var projects: [Project] = []
    
    var projectsTableViewHeight:CGFloat = 0
    let maxProjectsTableViewNr = 8
    
    let defaults = UserDefaults.standard
    
    var instanceSelected = false
    
    var projectId:NSNumber = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            instanceSelected = true
            getProjects(instanceId)
        }
        
        if let pId = defaults.value(forKey: "ProjectId") as? NSNumber {
            projectId = pId
        }
        
        settingsButton.tintColor = UIColor.white
        menuTableView.separatorStyle = .none
        projectsTableView.separatorStyle = .none
        projectsTableView.backgroundColor = Colors.paleOP.getUIColor()
        
        constraintProjectButtonWidth.constant = self.view.frame.width - 205
        projectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        menuTableView.tableHeaderView?.backgroundColor = UIColor.darkGray
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
 //           let project = Project.mr_findFirst(byAttribute: "id", withValue: projectId)
            if let project = Project.mr_findFirst(byAttribute: "id", withValue: projectId) {
                projectButton.setTitle("\(project.name!) \u{25BE}", for: .normal)
                projectButton.setTitle("\(project.name!) \u{25B4}", for: .selected)
            } else {
                projectButton.setTitle("Select Project \u{25BE}", for: .normal)
                projectButton.setTitle("Select Project \u{25B4}", for: .selected)
            }
        } else {
            projectButton.setTitle("Select Project \u{25BE}", for: .normal)
            projectButton.setTitle("Select Project \u{25B4}", for: .selected)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resizeProjectsView(_ sender: AnyObject) {
        projectsTableView.reloadData()
        
        let height:CGFloat = projectsTableViewHeight
        if (self.projectsViewConHeight.constant == 0) {
            self.projectButton.isSelected = true
        } else {
            self.projectButton.isSelected = false
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                if (self.projectsViewConHeight.constant == 0) {
                    self.projectsViewConHeight.constant = height
                } else {
                    self.projectsViewConHeight.constant = 0
                }
                self.view.layoutIfNeeded()
        }, completion: nil)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemSideMenuTableViewCell!
            let item = items[(indexPath as NSIndexPath).row];
            cell?.textLabel?.text = item.name()
            
            //check if instance selected
            if (instanceSelected) {
                cell?.textLabel?.textColor = UIColor.white
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
                if let menuId = defaults.value(forKey: "MenuId") as? Int {
                    if (item.name() == MenuItem.nameById(menuId)) {
                        menuTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    }
                } else {
                    menuTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
                    defaults.set(MenuItem.workPackages.id(), forKey: "MenuId")
                }
            } else {
            //disable cell selection if instance not selected
                cell?.textLabel?.textColor = UIColor.lightGray
                cell?.selectionStyle = .none
            }
            
            return cell!
        case projectsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectItemSideMenuTableViewCell!
            cell?.accessoryType = .none
            let project = projects[(indexPath as NSIndexPath).row]
            cell?.textLabel?.text = project.name
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
                projectButton.setTitle(p.name, for: .normal)
                defaults.set(Int(p.id!), forKey: "ProjectId")
                self.defaults.set(nil, forKey: "WorkPackageLastUpdate")
                getPrioritiesStatusesTypesFromServer()
                projectButton.sendActions(for: .touchUpInside)
                break
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (tableView) {
        case menuTableView:
            return 1.0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch (tableView) {
        case menuTableView:
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
            headerView.backgroundColor = UIColor.lightGray
        
            let label = UILabel()
            label.text = " "
            headerView.addSubview(label)
            return headerView
        default:
            return nil
        }
    }
    
    //SettingsViewController delegate implementation
    func settingsClosed(instanceChanged: Bool) {
        if instanceChanged {
            self.defaults.set(nil, forKey: "ProjectId")
            self.defaults.set(nil, forKey: "CanCreateWP")
        }
        
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            getRemoteProjects(instanceId)
            self.defaults.set(nil, forKey: "WorkPackageLastUpdate")
            self.projectsViewConHeight.constant = 0
            self.instanceSelected = true
        }
    }
    
    func getProjects(_ instanceId: String) {
        
        self.projects = Project.mr_findAllSorted(by: "name", ascending: true) as! [Project]
        
        if projects.count > 0 {
            self.projectsTableView.reloadData()
        }
        else
        {
      //      getRemoteProjects(instanceId)
        }
    }
    
    func getRemoteProjects(_ instanceId: String) {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getProjects(instanceId, onCompletion: {(responseObject:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                self.showRequestErrorAlert(error: issue)
                LoadingUIView.hide()
            } else {
                if responseObject {
                    self.projects = Project.mr_findAllSorted(by: "name", ascending: true) as! [Project]
                    self.projectsTableView.reloadData()
                    self.menuTableView.reloadData()
                    self.projectButton.isEnabled = true
                    
                }
                LoadingUIView.hide()
            }
        })
    }
    
    func getPrioritiesStatusesTypesFromServer() {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getPrioritiesStatusesTypes(onCompletion: {(success:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                self.defaults.set(false, forKey: "CanCreateWP")
                self.getPrioritiesStatusesTypesFromServerOneByOne()
            } else {
                LoadingUIView.hide()
                self.defaults.set(true, forKey: "CanCreateWP")
                self.delegate?.projectSelected()
            }
        })
    }
    
    func getPrioritiesStatusesTypesFromServerOneByOne() {
        OpenProjectAPI.sharedInstance.getPriorities(onCompletion: {(success:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                self.showRequestErrorAlert(error: issue)
                LoadingUIView.hide()
            } else {
                OpenProjectAPI.sharedInstance.getStatuses(onCompletion: {(success:Bool, error:NSError?) in
                    if let issue = error {
                        print(issue.description)
                        self.showRequestErrorAlert(error: issue)
                        LoadingUIView.hide()
                    } else {
                        OpenProjectAPI.sharedInstance.getTypes(onCompletion: {(success:Bool, error:NSError?) in
                            if let issue = error {
                                print(issue.description)
                                self.showRequestErrorAlert(error: issue)
                                LoadingUIView.hide()
                            } else {
                                self.delegate?.projectSelected()
                                LoadingUIView.hide()
                            }
                        })
                    }
                })
            }
        })
    }
    
    func showRequestErrorAlert(error: Error) {
        let alertController = ErrorAlerts.getAlertController(error: error, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
}
