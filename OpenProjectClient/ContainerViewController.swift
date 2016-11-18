//
//  ContainerViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

enum SlideOutState {
    case allCollapsed
    case leftPanelExpanded
}

@objc
protocol ContainerViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func collapseSidePanels()
}

class ContainerViewController: UIViewController {
    var centerNavigationController: UINavigationController!
    
    var currentState: SlideOutState = .allCollapsed {
        didSet {
            let shouldShowShadow = currentState != .allCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SideMenuViewController?
    
    let centerPanelExpandedOffset: CGFloat = 180
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showWorkPackages()
        //showActivities()
        centerNavigationController.didMove(toParentViewController: self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
        activitiesViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(ContainerViewControllerDelegate.toggleLeftPanel))
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
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func coverCenterNavigationControllerTransparent() {
        let totalWidth = centerNavigationController.navigationBar.frame.width
        let totalHeight = centerNavigationController.view.frame.height
        let navigationBarHeight = centerNavigationController.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let transparentView = UIView(frame: CGRect(
            x: 0,
            y: navigationBarHeight + statusBarHeight,
            width: totalWidth,
            height: totalHeight))
        transparentView.tag = 1
        centerNavigationController.view.addSubview(transparentView)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContainerViewControllerDelegate.toggleLeftPanel))
        transparentView.addGestureRecognizer(gestureRecognizer)
    }
    
    func removeTransparentFromCenterNavigationController() {
        let views = centerNavigationController.view.subviews
        for view in views {
            if (view.tag == 1) {
                view.removeFromSuperview()
            }
        }
    }
    
    func collapseSidePanels() {
        let expanded = (currentState == .leftPanelExpanded)
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
    
    func menuItemTapped(_ item: MenuItem) {
        let vc = item.viewController()
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(ContainerViewControllerDelegate.toggleLeftPanel))
        defaults.set(item.id(), forKey: "MenuId")
        self.centerNavigationController.viewControllers = [vc]
        self.toggleLeftPanel()
    }
    
    func projectSelected() {
        if let menuId = defaults.value(forKey: "MenuId") as? Int {
            let menuItem = MenuItem.menuItemById(menuId)
            if let item = menuItem as MenuItem! {
                menuItemTapped(item)
            }
        }
    }
    
    func addChildSidePanelController(_ sidePanelController: SideMenuViewController) {
        sidePanelController.delegate = self;
        
        view.insertSubview(sidePanelController.view, at: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
            coverCenterNavigationControllerTransparent()
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .allCollapsed
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil
            }
            self.removeTransparentFromCenterNavigationController()
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    //this is causing lags - http://stackoverflow.com/questions/27311917/shadow-lagging-the-user-interface
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            //centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            //centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch (recognizer.state) {
        case .began:
            if (currentState == .allCollapsed) {
                    if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                    showShadowForCenterViewController(true)
                }
            }
        case .changed:
            if (leftViewController != nil) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
            
        case .ended:
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


