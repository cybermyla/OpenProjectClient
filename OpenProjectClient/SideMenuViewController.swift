//
//  SidePanelViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func menuItemTapped(item: MenuItem)
    func projectSelected(projectId: Int)
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
}

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: SideMenuViewControllerDelegate?
    
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var projectsView: UIView!
    @IBOutlet weak var projectsTableView: UITableView!
    
    @IBOutlet weak var projectsViewConHeight: NSLayoutConstraint!
    
    var items: [MenuItem] = [.WorkPackages, .Activities]
    var projects: [Project] = []
    
    var projectsTableViewHeight:CGFloat = 0
    let maxProjectsTableViewNr = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        menuTableView.separatorStyle = .None
    }
    
    override func viewDidAppear(animated: Bool) {
        projectsViewConHeight.constant = 0
        if let indexPath = AppState.sharedInstance.projectIndexPath {
            projectsTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Middle)
        }
        
        if (projects.count > 0) {
            let projectsRowHeight = projectsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).height
            if projects.count <= maxProjectsTableViewNr {
                projectsTableViewHeight = CGFloat(projects.count) * projectsRowHeight
            } else {
                projectsTableViewHeight = CGFloat(10) * projectsRowHeight
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        projects = ProjectManager.getProjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func test(sender: AnyObject) {
        let height:CGFloat = projectsTableViewHeight
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                if (self.projectsViewConHeight.constant == 0) {
                    self.projectsViewConHeight.constant = height
                } else {
                    self.projectsViewConHeight.constant = 0
                }
                self.view.layoutIfNeeded()
            }, completion: nil)

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
            if (item.name() == AppState.sharedInstance.menuItem.name()) {
                menuTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
            return cell
        case projectsTableView:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell") as UITableViewCell!
            let project = projects[indexPath.row]
            cell.textLabel?.text = project.name
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (tableView) {
        case menuTableView:
            delegate?.menuItemTapped(MenuItem(rawValue: indexPath.row)!)
            break
        case projectsTableView:
            AppState.sharedInstance.projectIndexPath = indexPath
            delegate?.projectSelected(projects[indexPath.row].id!)
            break
        default:
            break
        }
    }
}
