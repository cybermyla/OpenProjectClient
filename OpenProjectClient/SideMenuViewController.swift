//
//  SidePanelViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func itemTapped(item: MenuItem)
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
}

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: SideMenuViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectsView: UIView!
    
    @IBOutlet weak var projectsViewConHeight: NSLayoutConstraint!
    
    var items: [String] = ["WorkPackages", "Activities"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.separatorStyle = .None
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        // projectsView.frame = CGRectMake(0, 0, 0, 0)
        projectsViewConHeight.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func test(sender: AnyObject) {
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                if (self.projectsViewConHeight.constant == 0) {
                    self.projectsViewConHeight.constant = 300
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
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell") as UITableViewCell!
        cell.textLabel?.text = items[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.itemTapped(MenuItem(rawValue: indexPath.row)!)
    }
    
    
    

}
