//
//  WPActivityVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 07/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackageActivityVC: UIViewController, AddWorkPackageVCDelegate {

    @IBOutlet weak var textViewActivities: UITextView!
    
    @IBOutlet weak var buttonAddActivity: UIButton!
    
    var workPackage: WorkPackage?
    var activities: [WorkPackageActivity]?
    private var userHrefs: [String] = []
    private var userHrefsIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        textViewActivities.isEditable = false
        textViewActivities.isScrollEnabled = true
        buttonAddActivity.backgroundColor = Colors.darkAzureOP.getUIColor()
        buttonAddActivity.tintColor = UIColor.white
        
        self.title = "Activities"
        
        loadActivities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowAddComment" {
            let vc = segue.destination as! AddWorkpackageActivityVC
            vc.delegate = self
            vc.workPackage = self.workPackage
        }
    }
    
    
    func loadActivities() {
        LoadingUIView.show()
        if let href = self.workPackage?.activitiesHref {
            OpenProjectAPI.sharedInstance.getActivities(href: href, onCompletion: {(responseObject:Bool, error:NSError?) in
                if let issue = error {
                    print(issue.description)
                    self.showRequestErrorAlert(error: issue)
                    LoadingUIView.hide()
                } else {
                    OpUser.mr_truncateAll()
                    self.activities = WorkPackageActivity.mr_findAllSorted(by: "createdAt", ascending: false) as! [WorkPackageActivity]?
                    self.getDistinctUserHrefs()
                    self.getUserDetail()
                    
                }
            })
        }
    }
    
    func getUserDetail() {
        if userHrefs.count > 0 {
        let href = userHrefs[self.userHrefsIndex]
            OpenProjectAPI.sharedInstance.getUser(href: href, onCompletion: {(responseObject:Bool, error:NSError?) in
                if let issue = error {
                    print(issue.description)
                    self.showRequestErrorAlert(error: issue)
                    LoadingUIView.hide()
                } else {
                    self.userHrefsIndex = self.userHrefsIndex + 1
                    if self.userHrefsIndex < self.userHrefs.count {
                        self.getUserDetail()
                    } else {
                        self.showActivities()
                        LoadingUIView.hide()
                    }
                }
            })
        } else {
            print("user hrefs count is 0")
        }
    }
    
    func getDistinctUserHrefs() {
        for activity in self.activities! {
            if let userHref = activity.user_href {
                if !userHrefs.contains(userHref) {
                    userHrefs.append(userHref)
                }
            }
        }
    }
    
    func showActivities() {
        //self.activities = WorkPackageActivity.mr_findAll() as? [WorkPackageActivity]
        self.textViewActivities.attributedText = self.createHtmlAttributedString()
    }
    
    func createHtmlAttributedString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(("<html>".data(using: .utf8)?.attributedString)!)
        //result.append((".name { size: 16px; }".data(using: .utf8)?.attributedString)!)
        //result.append(("</style></head>".data(using: .utf8)?.attributedString)!)
            let opUsers = OpUser.mr_findAll() as! [OpUser]
            for activity in self.activities! {
                var name = "N/A"
                if let i = opUsers.index(where: {$0.href == activity.user_href}) {
                    name = opUsers[i].name!
                }
                var rowActivity = "<div style=\"font-size:14px;font-family:HelveticaNeue\">"
                
                rowActivity += "<span style=\"font-size:18px;color:#00466C;font-weight:bold\">\(name)</span><br />"
                if let date = activity.createdAt as? Date {
                    rowActivity += "<span style=\"font-size:12px;\">updated on </span><span style=\"font-size:12px;color:#00466C;\">\(Tools.dateToFormatedString(date: date, dateStyle: .medium , timeStyle: .medium))</span>"
                }
                
                if let details = activity.details as? [String] {
                    if details.count > 0 {
                    rowActivity += "<ul>"
                    
                    for detail in details {
                        if detail.characters.count > 0 {
                            rowActivity += "<li>\(detail)</li>"
                        }
                    }
                    rowActivity += "</ul>"
                    }
                }
                
                if let comment = activity.comment_html {
                    rowActivity += "<div>\(comment)</div>"
                }
                
                rowActivity += "</div>"
                result.append((rowActivity.data(using: .utf8, allowLossyConversion: false)?.attributedString)!)
            }
        
        result.append(("</html>".data(using: .utf8)?.attributedString)!)
        return result
    }
    
    func commentSubmitted() {
        self.userHrefsIndex = 0
        self.userHrefs = []
        self.loadActivities()
    }
    
    func showRequestErrorAlert(error: Error) {
        let alertController = ErrorAlerts.getAlertController(error: error, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
