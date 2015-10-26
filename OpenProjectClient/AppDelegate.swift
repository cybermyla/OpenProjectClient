//
//  AppDelegate.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let containerViewController = ContainerViewController()
        
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = Colors.DarkAzureOP.getUIColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UIToolbar.appearance().barTintColor = Colors.DarkAzureOP.getUIColor()
        UIToolbar.appearance().tintColor = UIColor.whiteColor()
        
        UITableView.appearance().backgroundColor = UIColor.clearColor()
        UITableViewCell.appearance().backgroundColor = UIColor.clearColor()
        
        UITextField.appearance().backgroundColor = UIColor.whiteColor()
        UITextField.appearance().borderStyle = .None
        UITextField.appearance().font = UIFont(name: "System", size: 20.0)
        
        UITextField.appearance().tintColor = Colors.DarkAzureOP.getUIColor()
        
        let colorView = UIView()
        colorView.backgroundColor = Colors.DarkAzureOP.getUIColor()
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        
        UIButton.appearance().tintColor = UIColor.whiteColor()

        mockupData()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func mockupData() {
        for index in 1...50 {
            ProjectManager.mockupProject(index)
            WorkPackageManager.mockupWorkPackages(index, count: 15)
        }
        
        let instance = Instance(name: "Prvni instance", address: "http://blabla", login: "mila", password: "pass")
        
        SettingsManager.addInstance(instance)
    }

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func leftViewController() -> SideMenuViewController? {
        let sideMenu: SideMenuViewController = (mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SideMenuViewController)!
        sideMenu.view.backgroundColor = Colors.LightAzureOP.getUIColor()
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
    
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
    }
    
    class func addEditInstanceVC() -> AddEditInstanceVC? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("AddEditInstanceVC") as? AddEditInstanceVC
    }
}

