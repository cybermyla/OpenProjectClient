//
//  NewWorkPackageViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class NewWorkPackageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var workpackage: WorkPackage?
    var workpackageForm: WorkPackageForm?
    
    private var sections: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = workpackage {
            self.navigationItem.title = "Edit Work Package"
        } else {
            self.navigationItem.title = "New Work Package"
        }
        
        getNewForm()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        setupGraphics()
 //       getAvailableAssignees()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        get {
            return true
        }
    }
    
    private func setupGraphics() {
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        nextButton.backgroundColor = Colors.darkAzureOP.getUIColor()
        nextButton.tintColor = UIColor.white
        
        cancelButton.backgroundColor = Colors.lightAzureOP.getUIColor()
        cancelButton.tintColor = UIColor.white
        
        tableView.backgroundColor = UIColor.white
    }
    
    private func defineSections() {
        var items1 = [SectionItem]()
        items1.append(SectionItem(name: "Subject", value: (workpackageForm?.subject)!, type: WpAttributes.subject))
        if let description = workpackageForm?.description_raw {
            items1.append(SectionItem(name: "Description", value: description, type: WpAttributes.description))
        } else {
            items1.append(SectionItem(name: "Description", value: "", type: WpAttributes.description))
        }
        sections.append(Section(heading: "", items: items1))
        
        var items2 = [SectionItem]()
        if let type = workpackageForm?.type_title {
            items2.append(SectionItem(name: "Type", value: type, type: WpAttributes.type))
        } else {
            items2.append(SectionItem(name: "Type", value: "-", type: WpAttributes.type))
        }
        if let status = workpackageForm?.status_title {
            items2.append(SectionItem(name: "Status", value: status, type: WpAttributes.status))
        } else {
            items2.append(SectionItem(name: "Status", value: "-", type: WpAttributes.status))
        }
        items2.append(SectionItem(name: "Progress", value: "-", type: WpAttributes.progress))
        items2.append(SectionItem(name: "Date", value: "-", type: WpAttributes.date))
        
        if let priority = workpackageForm?.priority_title {
            items2.append(SectionItem(name: "Priority", value: priority, type: WpAttributes.priority))
        } else {
            items2.append(SectionItem(name: "Priority", value: "-", type: WpAttributes.priority))
        }
        if let version = workpackageForm?.version_title {
            items2.append(SectionItem(name: "Version", value: version, type: WpAttributes.version))
        } else {
            items2.append(SectionItem(name: "Version", value: "-", type: WpAttributes.version))
        }
        sections.append(Section(heading: "Details", items: items2))
        
        var items3 = [SectionItem]()
        items3.append(SectionItem(name: "Assignee", value: "-", type: WpAttributes.assignee))
        items3.append(SectionItem(name: "Responsible", value: "-", type: WpAttributes.responsible))
        sections.append(Section(heading: "People", items: items3))
        
        var items4 = [SectionItem]()
        items4.append(SectionItem(name: "Estimated Time", value: "-", type: WpAttributes.estimatedTime))
        items4.append(SectionItem(name: "Remaining Hours", value: "-", type: WpAttributes.remainingHours))
        sections.append(Section(heading: "Estimates & Time", items: items4))
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
 
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].heading
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewWorkPackageTableViewCell") as! NewWorkPackageTVC!
        let item = sections[indexPath.section].items[indexPath.row]
        cell?.accessoryType = .disclosureIndicator
        cell?.selectionStyle = .none
        cell?.name.text = item.name
        cell?.value.text = item.value
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        switch selectedItem.type {
        case WpAttributes.subject:
            let vc = UIStoryboard.EditSubjectVC()
            vc?.type = WpAttributes.subject
            self.show(vc!, sender: self)
            break
        case WpAttributes.description:
            let vc = UIStoryboard.EditSubjectVC()
            vc?.type = WpAttributes.description
            self.show(vc!, sender: self)
            break
        case WpAttributes.type:
            break
        case WpAttributes.status:
            break
        case WpAttributes.progress:
            break
        case WpAttributes.date:
            break
        case WpAttributes.priority:
            break
        case WpAttributes.version:
            break
        case WpAttributes.assignee:
            break
        case WpAttributes.responsible:
            break
        case WpAttributes.estimatedTime:
            break
        case WpAttributes.remainingHours:
            break
        default:
            break
        }
    }
    
    private struct Section {
        var heading: String
        var items: [SectionItem]
        
        init(heading: String, items: [SectionItem]) {
            self.heading = heading
            self.items = items
        }
    }
    
    private struct SectionItem {
        var name: String
        var value: String
        var type: WpAttributes
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
    
    func getNewForm() {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getWorkpackagesCreateFormsPayload(onCompletion: {(responseObject:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                LoadingUIView.hide()
            } else {
                self.workpackageForm = WorkPackageForm.mr_findFirst() as WorkPackageForm
                self.defineSections()
                self.tableView.reloadData()
                LoadingUIView.hide()
            }
        })
    }
}


