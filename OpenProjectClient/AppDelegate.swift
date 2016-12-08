//
//  AppDelegate.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//
import UIKit
import CoreData
import MagicalRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let containerViewController = ContainerViewController()
        
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        
        setAppearance()
    
        MagicalRecord.setupCoreDataStack(withStoreNamed: "DataModel")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func setAppearance() {
        
        UINavigationBar.appearance().barTintColor = Colors.darkAzureOP.getUIColor()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UIToolbar.appearance().barTintColor = Colors.darkAzureOP.getUIColor()
        UIToolbar.appearance().tintColor = UIColor.white
 
        
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        UITextField.appearance().backgroundColor = UIColor.white
        UITextField.appearance().borderStyle = .none
        UITextField.appearance().font = UIFont(name: "System", size: 20.0)
        
        UITextField.appearance().tintColor = Colors.darkAzureOP.getUIColor()
        
        let darkColorView = UIView()
        darkColorView.backgroundColor = Colors.darkAzureOP.getUIColor()

        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear
 
        
        UITableViewCell.appearance().selectedBackgroundView = darkColorView
        UITableViewCell.appearance(whenContainedInInstancesOf: [InstanceTableViewCell.self]).selectedBackgroundView = clearView
 
        //UIButton.appearance(whenContainedInInstancesOf: [SideMenuViewController.self]).tintColor = UIColor.white
        //UIButton.appearance(whenContainedInInstancesOf: [SettingsViewController.self]).tintColor = UIColor.white
        UIButton.appearance(whenContainedInInstancesOf: [AddEditInstanceVC.self]).tintColor = UIColor.white
        
        UIButton.appearance(whenContainedInInstancesOf: [FilterTableViewCell.self]).tintColor = Colors.darkAzureOP.getUIColor()
        
        UIButton.appearance(whenContainedInInstancesOf: [InstanceTableViewCell.self]).tintColor = Colors.darkAzureOP.getUIColor()
 
 
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
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func leftViewController() -> SideMenuViewController? {
        let sideMenu: SideMenuViewController = (mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SideMenuViewController)!
        //sideMenu.view.backgroundColor = Colors.lightAzureOP.getUIColor()
        sideMenu.view.backgroundColor = UIColor.black
        return sideMenu
    }
    
    class func workPackagesViewController() -> WorkPackagesViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "WorkPackagesViewController") as? WorkPackagesViewController
    }
    
    class func activitiesViewController() -> ActivitiesViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ActivitiesViewController") as? ActivitiesViewController
    }
    
    class func filterAddEditViewController() -> FilterAddEditViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "FilterAddEditViewController") as? FilterAddEditViewController
    }
    
    class func wpEditViewController() -> NewWorkPackageVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "NewWorkPackageVC") as? NewWorkPackageVC
    }
    
    class func wpDetailViewController() -> WorkPackageDetailVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "WorkPackageDetailVC") as? WorkPackageDetailVC
    }
    
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
    }
    
    class func addEditInstanceVC() -> AddEditInstanceVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "AddEditInstanceVC") as? AddEditInstanceVC
    }
    
    class func EditSubjectVC() -> EditLongTextVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "EditLongTextVC") as? EditLongTextVC
    }
    
    class func EditMultipleChoicesVC() -> EditMultipleChoicesVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "EditMultipleChoicesVC") as? EditMultipleChoicesVC
    }
    
    class func EditDateVC() -> EditDateVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "EditDateVC") as? EditDateVC
    }
    
    class func EditHoursVC() -> EditHoursVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "EditHoursVC") as? EditHoursVC
    }
    
    class func WorkPackageActivityVC() -> WorkPackageActivityVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "WorkPackageActivityVC") as? WorkPackageActivityVC
    }
}

