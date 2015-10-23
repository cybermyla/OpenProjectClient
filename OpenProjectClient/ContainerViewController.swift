//
//  ContainerViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

enum SlideOutState {
    case AllCollapsed
    case LeftPanelExpanded
}

@objc
protocol ContainerViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class ContainerViewController: UIViewController {
    var centerNavigationController: UINavigationController!
    
    var currentState: SlideOutState = .AllCollapsed {
        didSet {
            let shouldShowShadow = currentState != .AllCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SideMenuViewController?
    
    let centerPanelExpandedOffset: CGFloat = 140
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showWorkPackages()
        //showActivities()
        centerNavigationController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showActivities() {
        var activitiesViewController: ActivitiesViewController!
        activitiesViewController = UIStoryboard.activitiesViewController()
        activitiesViewController.delegate = self
        activitiesViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "toggleLeftPanel")
        centerNavigationController = UINavigationController(rootViewController: activitiesViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
    }
    
    func showWorkPackages() {
        var workPackagesViewController: WorkPackagesViewController!
        workPackagesViewController = UIStoryboard.workPackagesViewController()
        workPackagesViewController.delegate = self
        centerNavigationController = UINavigationController(rootViewController: workPackagesViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
    }

}

extension ContainerViewController: ContainerViewControllerDelegate, SideMenuViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        let expanded = (currentState == .LeftPanelExpanded)
        if expanded {
            toggleLeftPanel()
        }
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            //show something in the panel (or not) menu
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func itemTapped(item: MenuItem) {
        let vc = item.viewController()
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "toggleLeftPanel")
        self.centerNavigationController.viewControllers = [vc]
        self.toggleLeftPanel()
    }
    
    func addChildSidePanelController(sidePanelController: SideMenuViewController) {
        sidePanelController.delegate = self;
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            //UIApplication.sharedApplication().statusBarHidden = false
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .AllCollapsed
                self.leftViewController!.view.removeFromSuperview()
                
                self.leftViewController = nil
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch (recognizer.state) {
        case .Began:
            if (currentState == .AllCollapsed) {
                    if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                    showShadowForCenterViewController(true)
                }
            }
        case .Changed:
            if (leftViewController != nil) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }
            
        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func leftViewController() -> SideMenuViewController? {
        let sideMenu: SideMenuViewController = (mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SideMenuViewController)!
        sideMenu.view.backgroundColor = UIColor.whiteColor()
        return sideMenu
    }
    
    class func workPackagesViewController() -> WorkPackagesViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("WorkPackagesViewController") as? WorkPackagesViewController
    }
    
    class func activitiesViewController() -> ActivitiesViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ActivitiesViewController") as? ActivitiesViewController
    }
    
    class func filtersViewController() -> WPFiltersViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("WPFiltersViewController") as? WPFiltersViewController
    }
    
    class func newWorkpackageViewController() -> NewWorkPackageViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("NewWorkPackageViewController") as? NewWorkPackageViewController
    }
}
