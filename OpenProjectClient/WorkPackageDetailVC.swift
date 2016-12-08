//
//  WPDetailViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackageDetailVC: UIViewController, NewWorkPackageVCDelegate {
    
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!

    @IBOutlet weak var labelTypeUpdateAuthor: UILabel!
    
    @IBOutlet weak var labelTypeStatusPriority: UILabel!
    
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var labelProgress: UILabel!
    
    @IBOutlet weak var pvProgress: UIProgressView!
    
    @IBOutlet weak var labelVersion: UILabel!
    
    @IBOutlet weak var labelCategory: UILabel!
    
    @IBOutlet weak var labelResponsible: UILabel!
    
    @IBOutlet weak var labelAssignee: UILabel!
    
    @IBOutlet weak var labelEstimatedRemaining: UILabel!
    
    @IBOutlet weak var labelSpent: UILabel!
    
    
    var workpackage: WorkPackage?
    
    let defaults = UserDefaults.standard
    var instanceId: String?
    var projectId: NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //disable description textview editing
        textViewDescription.isEditable = false
        fillWP()
    }
    
    /* My functions */
    
    func fillWP() {
        if let wp = workpackage {
            labelSubject.font = UIFont.boldSystemFont(ofSize: 18)
            labelSubject.textColor = Colors.darkAzureOP.getUIColor()
            labelSubject.text = wp.subject!
            labelSubject.lineBreakMode = .byWordWrapping
            labelSubject.numberOfLines = 0
            
            let date = Tools.dateToFormatedString(date: wp.updatedAt! as Date, dateStyle: .short, timeStyle: .short)
            labelTypeUpdateAuthor.text = "\(wp.typeTitle!) #\(wp.id): Created by \(wp.authorTitle!).\nLast updated on \(date)"
            labelTypeUpdateAuthor.font = UIFont.systemFont(ofSize: 12)
            labelTypeUpdateAuthor.lineBreakMode = .byWordWrapping
            labelTypeUpdateAuthor.numberOfLines = 2
            
            if let description = wp.descriptionHtml {
                if description != "null" {
                    textViewDescription.attributedText = "<html style=\"font-family:HelveticaNeue;font-size:14px;\">\(description)</html>".data(using: .utf8)?.attributedString
                } else {
                    textViewDescription.text = ""
                }
            } else {
                textViewDescription.text = ""
            }
            

            let finaAttributedString = NSMutableAttributedString()
            if let value = wp.typeTitle {
                finaAttributedString.append(Tools.createFormatedLabel("Type", str: value))
            }
            if let value = wp.priorityTitle {
                finaAttributedString.append(Tools.createFormatedLabel("Priority", str: value))
            }
            if let value = wp.statusTitle {
                finaAttributedString.append(Tools.createFormatedLabel("Status", str: value))
            }
            
            labelTypeStatusPriority.attributedText = finaAttributedString
            labelTypeStatusPriority.font = UIFont.systemFont(ofSize: 14)
            
            var startDate = "No start date"
            var endDate = "No end date"
            if let dtStartDate = wp.startDate as Date! {
                startDate = dtStartDate.shortDate
            }
            if let dtEndDate = wp.dueDate as Date! {
                endDate = dtEndDate.shortDate
            }
            let dateAndProgressAttributedString = NSMutableAttributedString()
            dateAndProgressAttributedString.append(Tools.createFormatedLabel("Date", str: "\(startDate) - \(endDate)"))
            dateAndProgressAttributedString.append(Tools.createFormatedLabel("Progress", str: "\(wp.percentageDone) %"))
            labelDate.attributedText = dateAndProgressAttributedString
            labelDate.font = UIFont.systemFont(ofSize: 14)
    
            if let value = wp.versionTitle {
                labelVersion.attributedText = Tools.createFormatedLabel("Version", str: value)
            } else {
                labelVersion.attributedText = Tools.createFormatedLabel("Version", str: "-")
            }
            labelVersion.font = UIFont.systemFont(ofSize: 14)
            
            if let value = wp.categoryTitle {
                labelCategory.attributedText = Tools.createFormatedLabel("Category", str: value)
            } else {
                labelCategory.attributedText = Tools.createFormatedLabel("Category", str: "-")
            }
            labelCategory.font = UIFont.systemFont(ofSize: 14)
            
            if let assignee = wp.assigneeTitle as String! {
                labelAssignee.attributedText = Tools.createFormatedLabel("Assignee", str: assignee)
            } else {
                labelAssignee.attributedText = Tools.createFormatedLabel("Assignee", str: "-")
            }
            labelAssignee.font = UIFont.systemFont(ofSize: 14)
            
            if let responsible = wp.responsibleTitle as String! {
                labelResponsible.attributedText = Tools.createFormatedLabel("Responsible", str: responsible)
            } else {
                labelResponsible.attributedText = Tools.createFormatedLabel("Responsible", str: "-")
            }
            labelResponsible.font = UIFont.systemFont(ofSize: 14)
            
            let timeAttributedString = NSMutableAttributedString()
            if wp.estimatedTime > -1 {
                timeAttributedString.append(Tools.createFormatedLabel("Estimated Time", str: "\(wp.estimatedTime)h "))
            } else {
                timeAttributedString.append(Tools.createFormatedLabel("Estimated Time", str: "-"))
            }
            if wp.remainingHours > -1 {
                timeAttributedString.append(Tools.createFormatedLabel("Remaining Hours", str: "\(wp.remainingHours)h"))
            } else {
                timeAttributedString.append(Tools.createFormatedLabel("Remaining Hours", str: "-"))
            }
            labelEstimatedRemaining.attributedText = timeAttributedString
            labelEstimatedRemaining.font = UIFont.systemFont(ofSize: 14)
            
            labelSpent.attributedText = Tools.createFormatedLabel("Spent", str: "not implemented")
            labelSpent.font = UIFont.systemFont(ofSize: 14)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
   
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        let vc = UIStoryboard.wpEditViewController()
        vc?.workpackage = self.workpackage
        let nav = UINavigationController(rootViewController: vc!)
        self.present(nav, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "ShowActivities":
            let vc = segue.destination as! WorkPackageActivityVC
            vc.workPackage = self.workpackage
            break
        default:
            break
        }
    }
    
    func workpackageCreationUpdateFinished(workPackageId: Int32) {
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            if let projectId = defaults.value(forKey: "ProjectId") as? NSNumber {
                workpackage = WorkPackage.getWorkPackage(id: workPackageId, projectId: projectId, instanceId: instanceId)
                fillWP()
            }
        }
    }
}

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension Date {
    struct Formatter {
        static let shortDate = DateFormatter(dateFormat: "MM/dd/yyyy")
    }
    var shortDate: String {
        return Formatter.shortDate.string(from: self)
    }
}
