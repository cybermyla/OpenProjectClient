//
//  WPDetailViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WPDetailViewController: UIViewController {
    
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var typeNrStatus: UILabel!
    @IBOutlet weak var labelUpdated: UILabel!
    @IBOutlet weak var labelCreated: UILabel!
    @IBOutlet weak var labelAssginee: UILabel!
    @IBOutlet weak var labelResponsible: UILabel!
    @IBOutlet weak var lableEstimate: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    var workpackage: WorkPackage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        fillWP()
    }
    
    /* My functions */
    
    func fillWP() {
        if let wp = workpackage {
            labelSubject.font = UIFont.boldSystemFontOfSize(22)
            labelSubject.text = wp.subject!
            labelSubject.lineBreakMode = .ByWordWrapping
            labelSubject.numberOfLines = 0
            
            typeNrStatus.text = "\(wp.typeTitle!) #\(wp.id!) - \(wp.statusTitle!) (\(wp.priorityTitle!))"
            typeNrStatus.font = UIFont.boldSystemFontOfSize(18)
            
            textViewDescription.text = wp.descriptionRaw!
            
            labelUpdated.text = "Last update on \(wp.updatedAt!.shortDate)"
            labelUpdated.font = UIFont.italicSystemFontOfSize(14)
            
            labelCreated.text = "Created by \(wp.authorTitle!) on \(wp.createdAt!.shortDate)"
            labelCreated.font = UIFont.italicSystemFontOfSize(14)
            
            if let assignee = wp.assigneeTitle as String! {
                labelAssginee.text = "Assignee: \(assignee)"
            } else {
                labelAssginee.text = "Assignee: -"
            }
            labelAssginee.font = UIFont.systemFontOfSize(14)
            
            if let responsible = wp.responsibleTitle as String! {
                labelResponsible.text = "Responsible: \(responsible)"
            } else {
                labelResponsible.text = "Responsible: -"
            }
            labelResponsible.font = UIFont.systemFontOfSize(14)
            
            var startDate = "No start date"
            var endDate = "No end date"
            if let dtStartDate = wp.startDate as NSDate! {
                startDate = dtStartDate.shortDate
            }
            if let dtEndDate = wp.dueDate as NSDate! {
                endDate = dtEndDate.shortDate
            }
            labelDate.text = "Date: \(startDate) - \(endDate)"
            labelDate.font = UIFont.systemFontOfSize(14)
            
            lableEstimate.font = UIFont.systemFontOfSize(14)
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
   
    @IBAction func editButtonTapped(sender: AnyObject) {
        let vc = UIStoryboard.wpEditViewController()
        vc?.workpackage = self.workpackage
        let nav = UINavigationController(rootViewController: vc!)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
/*
extension NSData {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
extension String {
    var utf8Data: NSData? {
        return dataUsingEncoding(NSUTF8StringEncoding)
    }
}
*/

extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension NSDate {
    struct Formatter {
        static let shortDate = NSDateFormatter(dateFormat: "MM/dd/yyyy")
    }
    var shortDate: String {
        return Formatter.shortDate.stringFromDate(self)
    }
}
