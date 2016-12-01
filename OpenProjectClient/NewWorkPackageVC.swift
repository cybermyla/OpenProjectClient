//
//  NewWorkPackageViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class NewWorkPackageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EditLongTextVCDelegate, EditMultipleChoicesVCDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var workpackage: WorkPackage?
    var workpackageForm: WorkPackageForm?
    
    private var sections: [Section] = []
    
    let defaults = UserDefaults.standard
    var instanceId: String = ""
    var projectId: NSNumber = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = workpackage {
            self.navigationItem.title = "Edit Work Package"
        } else {
            self.navigationItem.title = "New Work Package"
        }
        getAvailableAssignees()
        
        getNewForm()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        instanceId = defaults.value(forKey: "InstanceId") as! String!
        projectId = defaults.value(forKey: "ProjectId") as! NSNumber!
        
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        setupGraphics()
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
    
    //always testing if name exists - not all have to be defined
    private func defineSections() {
        sections = []
        var items1 = [SectionItem]()
        if let name = workpackageForm?.subject_name {
            if let subject = workpackageForm?.subject_value {
                items1.append(SectionItem(name: getName(str: name, required: workpackageForm?.subject_required), value: subject, type: WpAttributes.subject))
            } else {
                items1.append(SectionItem(name: getName(str: name, required: workpackageForm?.subject_required), value: "-", type: WpAttributes.subject))
            }
        }
        if let name = workpackageForm?.description_name {
            if let description = workpackageForm?.description_raw {
                items1.append(SectionItem(name: getName(str: name, required: workpackageForm?.description_required), value: description, type: WpAttributes.description))
            } else {
                items1.append(SectionItem(name: getName(str: name, required: workpackageForm?.description_required), value: "", type: WpAttributes.description))
            }
        }
        sections.append(Section(heading: "", items: items1))
        
        var items2 = [SectionItem]()
        if let name = workpackageForm?.type_name {
            if let type = workpackageForm?.type_title {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.type_required), value: type, type: WpAttributes.type))
            } else {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.type_required), value: "- no type -", type: WpAttributes.type))
            }
        }
        if let name = workpackageForm?.status_name {
            if let status = workpackageForm?.status_title {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.status_required), value: status, type: WpAttributes.status))
            } else {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.status_required), value: "- no status -", type: WpAttributes.status))
            }
        }
        if let sname = workpackageForm?.startDate_name {
            if let dname = workpackageForm?.dueDate_name {
                if let startDate = workpackageForm?.startDate_value {
                    items2.append(SectionItem(name: getName(str: ("\(sname) - \(dname)"), required: workpackageForm?.startDate_required), value: dateToString(date: startDate), type: WpAttributes.date))
                } else {
                    items2.append(SectionItem(name: getName(str: ("\(sname) - \(dname)"), required: workpackageForm?.startDate_required), value: "- -", type: WpAttributes.date))
                }
            }
        }
        if let name = workpackageForm?.priority_name {
            if let priority = workpackageForm?.priority_title {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.priority_required), value: priority, type: WpAttributes.priority))
            } else {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.priority_required), value: "- no priority -", type: WpAttributes.priority))
            }
        }
        if let name = workpackageForm?.version_name {
            if let version = workpackageForm?.version_title {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.version_required), value: version, type: WpAttributes.version))
            } else {
                items2.append(SectionItem(name: getName(str: name, required: workpackageForm?.version_required), value: "- no version -", type: WpAttributes.version))
            }
        }
        sections.append(Section(heading: "Details", items: items2))
        
        var items3 = [SectionItem]()
        if let name = workpackageForm?.assignee_name {
            if let assignee = workpackageForm?.assignee_title {
                items3.append(SectionItem(name: getName(str: name, required: workpackageForm?.assignee_required), value: assignee, type: WpAttributes.assignee))
            } else {
                items3.append(SectionItem(name: getName(str: name, required: workpackageForm?.assignee_required), value: "- no assignee -", type: WpAttributes.assignee))
            }
        }
        if let name = workpackageForm?.responsible_name {
            if let responsible = workpackageForm?.responsible_title {
                items3.append(SectionItem(name: getName(str: name, required: workpackageForm?.responsibe_required), value: responsible, type: WpAttributes.responsible))
            } else {
                items3.append(SectionItem(name: getName(str: name, required: workpackageForm?.responsibe_required), value: "- no responsible -", type: WpAttributes.responsible))
            }
        }
        sections.append(Section(heading: "People", items: items3))
        
        var items4 = [SectionItem]()
        if let name = workpackageForm?.estimatedTime_name {
            if let estimated = workpackageForm?.estimatedTime_value {
                items4.append(SectionItem(name: getName(str: name, required: workpackageForm?.estimatedTime_required), value: estimated, type: WpAttributes.estimatedTime))
            } else {
                items4.append(SectionItem(name: getName(str: name, required: workpackageForm?.estimatedTime_required), value: "-", type: WpAttributes.estimatedTime))
            }
        }
        if let name = workpackageForm?.remainingTime_name {
            if let remaining = workpackageForm?.remainingTime_value {
                items4.append(SectionItem(name: getName(str: name, required: (workpackageForm?.remainingTime_required)!), value: remaining, type: WpAttributes.remainingHours))
            } else {
                items4.append(SectionItem(name: getName(str: name, required: workpackageForm?.remainingTime_required), value: "-", type: WpAttributes.remainingHours))
            }
        }
        sections.append(Section(heading: "Estimates & Time", items: items4))
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
 
    @IBAction func cancelButtonTapped(_ sender: Any) {
        WorkPackageForm.mr_truncateAll()
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
        cell?.name.attributedText = item.name
        cell?.value.text = item.value
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        switch selectedItem.type {
        case WpAttributes.subject:
            let vc = UIStoryboard.EditSubjectVC()
            if let subject = workpackageForm?.subject_value {
                vc?.text = subject
            }
            vc?.type = WpAttributes.subject
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.description:
            let vc = UIStoryboard.EditSubjectVC()
            if let desc = workpackageForm?.description_raw {
                vc?.text = desc
            }
            vc?.type = WpAttributes.description
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.type:
            let vc = UIStoryboard.EditMultipleChoicesVC()
            vc?.values = Type.getAllIdNameTuples(projectId, instanceId: instanceId)
            vc?.type = WpAttributes.type
            if let title = workpackageForm?.type_title {
                vc?.selectedTitle = title
            }
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.status:
            let vc = UIStoryboard.EditMultipleChoicesVC()
            vc?.values = Status.getAllIdNameTuples(projectId, instanceId: instanceId, alloweForNew: true)
            vc?.type = WpAttributes.status
            if let title = workpackageForm?.status_title {
                vc?.selectedTitle = title
            }
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.progress:
            break
        case WpAttributes.date:
            break
        case WpAttributes.priority:
            let vc = UIStoryboard.EditMultipleChoicesVC()
            vc?.values = Priority.getAllIdNameTuples(projectId, instanceId: instanceId)
            vc?.type = WpAttributes.priority
            if let title = workpackageForm?.priority_title {
                vc?.selectedTitle = title
            }
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.version:
            let vc = UIStoryboard.EditMultipleChoicesVC()
            var values = Version.getAllVersionsIdNameTuples(projectId, instanceId: instanceId)
            values.append((id: -1, name: "- no version -", href: "-"))
            vc?.values = values
            vc?.type = WpAttributes.version
            if let title = workpackageForm?.version_title {
                vc?.selectedTitle = title
            }
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.assignee:
            let vc = UIStoryboard.EditMultipleChoicesVC()
            var values = Assignee.getAllAvailableAssigneesIdNameTuples(projectId, instanceId: instanceId)
            values.append((id: -1, name: "- no assignee -", href: "-"))
            vc?.values = values
            vc?.type = WpAttributes.assignee
            if let title = workpackageForm?.assignee_title {
                vc?.selectedTitle = title
            }
            vc?.delegate = self
            self.show(vc!, sender: self)
            break
        case WpAttributes.responsible:
            let vc = UIStoryboard.EditMultipleChoicesVC()
            var values = Assignee.getAllAvailableResponsiblesdNameTuples(projectId, instanceId: instanceId)
            values.append((id: -1, name: "- no responsible -", href: "-"))
            vc?.values = values
            vc?.type = WpAttributes.responsible
            if let title = workpackageForm?.responsible_title {
                vc?.selectedTitle = title
            }
            vc?.delegate = self
            self.show(vc!, sender: self)
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
        var name: NSMutableAttributedString
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
    
    func updateForm() {
        self.workpackageForm = WorkPackageForm.mr_findFirst() as WorkPackageForm
        self.defineSections()
        self.tableView.reloadData()
    }
    
    func dateToString(date: NSDate) -> String {
        return "Some date"
    }
    
    
    //edit delegates implementation
    func longTextEditFinished() {
        updateForm()
    }
    
    func multipleChoicesEditFinished() {
        updateForm()
    }
    
    //item name - attributed string
    func getName(str: String?, required: Bool?) -> NSMutableAttributedString{
        let combination = NSMutableAttributedString()
        let plain = [NSForegroundColorAttributeName: UIColor.gray]
        let red = [NSForegroundColorAttributeName: UIColor.red]
        if let s: String = str {
            let partOne = NSMutableAttributedString(string: s, attributes: plain)
            let partTwo = NSMutableAttributedString(string: " *", attributes: red)
            combination.append(partOne)
            if let r = required {
                if r {
                    combination.append(partTwo)
                }
            }
        }
        return combination
    }
}


