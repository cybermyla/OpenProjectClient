//
//  NewWorkPackageViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class NewWorkPackageViewController: UIViewController {

    @IBOutlet weak var tfSubject: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var btStatus: UIButton!
    @IBOutlet weak var btType: UIButton!
    @IBOutlet weak var btPriority: UIButton!
    @IBOutlet weak var btAssignee: UIButton!
    @IBOutlet weak var btResponsible: UIButton!
    @IBOutlet weak var btStart: UIButton!
    @IBOutlet weak var btEnd: UIButton!
    @IBOutlet weak var btEstimatedTime: UIButton!
    @IBOutlet weak var btRemainingTime: UIButton!
    @IBOutlet weak var btVersion: UIButton!
    
    var workpackage: WorkPackage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = workpackage {
            self.navigationItem.title = "Edit Work Package"
        } else {
            self.navigationItem.title = "New Work Package"
        }
        
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        btStatus.backgroundColor = Colors.lightAzureOP.getUIColor()
        btType.backgroundColor = Colors.lightAzureOP.getUIColor()
        btPriority.backgroundColor = Colors.lightAzureOP.getUIColor()
        btVersion.backgroundColor = Colors.lightAzureOP.getUIColor()
        btAssignee.backgroundColor = Colors.lightAzureOP.getUIColor()
        btResponsible.backgroundColor = Colors.lightAzureOP.getUIColor()
        btStart.backgroundColor = Colors.lightAzureOP.getUIColor()
        btEnd.backgroundColor = Colors.lightAzureOP.getUIColor()
        btEstimatedTime.backgroundColor = Colors.lightAzureOP.getUIColor()
        btRemainingTime.backgroundColor = Colors.lightAzureOP.getUIColor()
        
        btStatus.tintColor = UIColor.white
        btType.tintColor = UIColor.white
        btPriority.tintColor = UIColor.white
        btVersion.tintColor = UIColor.white
        btAssignee.tintColor = UIColor.white
        btResponsible.tintColor = UIColor.white
        btStart.tintColor = UIColor.white
        btEnd.tintColor = UIColor.white
        btEstimatedTime.tintColor = UIColor.white
        btRemainingTime.tintColor = UIColor.white
        
        getAvailableAssignees()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveTapped(_ sender: AnyObject) {
        
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getAvailableAssignees() {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getAvailableAssignees(onCompletion: {(responseObject:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                LoadingUIView.hide()
            } else {
                //sending responsibles and assignee requests serialy - they share the same table
                self.getAvailableResponsibles()
            }
            
        })
    }
    
    func getAvailableResponsibles() {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getAvailableResponsibles(onCompletion: {(responseObject:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                LoadingUIView.hide()
            } else {
                LoadingUIView.hide()
            }
            
        })
    }
}
