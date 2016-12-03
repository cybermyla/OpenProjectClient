//
//  NewWorkPackageViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class NewWorkPackageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EditLongTextVCDelegate, EditMultipleChoicesVCDelegate, EditDateVCDelegate, EditHoursVCDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var workpackage: WorkPackage?
    var workpackageFormSchemaItems: [WorkPackageFormSchema]?
    
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
        let sectItems1 = WorkPackageFormSchema.getItemsBySection(section: 0)
        sections.append(Section(heading: "", items: getSectionItems(items: sectItems1)))
        
        let sectItems2 = WorkPackageFormSchema.getItemsBySection(section: 1)
        sections.append(Section(heading: "Details", items: getSectionItems(items: sectItems2)))
        
        let sectItems3 = WorkPackageFormSchema.getItemsBySection(section: 2)
        sections.append(Section(heading: "People", items: getSectionItems(items: sectItems3)))
        
        let sectItems4 = WorkPackageFormSchema.getItemsBySection(section: 3)
        sections.append(Section(heading: "Estimates & Time", items: getSectionItems(items: sectItems4)))
        
        let sectItems5 = WorkPackageFormSchema.getItemsBySection(section: 4)
        let section5 = Section(heading: "Custom", items: getSectionItems(items: sectItems5))
        if section5.items.count > 0 {
            sections.append(section5)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
 
    @IBAction func cancelButtonTapped(_ sender: Any) {
        WorkPackageFormSchema.mr_truncateAll()
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = Colors.lightAzureOP.getUIColor()
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 25))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = sections[section].heading
        label.textColor = UIColor.white
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewWorkPackageTableViewCell") as! NewWorkPackageTVC!
        let item = sections[indexPath.section].items[indexPath.row]
        cell?.accessoryType = .disclosureIndicator
        cell?.selectionStyle = .none
        cell?.name.attributedText = item.name
        cell?.value.text = item.value.value
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        if let type = WpTypes(rawValue: Int(selectedItem.value.type)) {
            switch type {
            case WpTypes.string, WpTypes.formattable:
                let vc = UIStoryboard.EditSubjectVC()
                vc?.schemaItem = selectedItem.value
                vc?.delegate = self
                self.show(vc!, sender: self)
                break
            case WpTypes.stringObject:
                let vc = UIStoryboard.EditMultipleChoicesVC()
                vc?.schemaItem = selectedItem.value
                vc?.values = StringObjectValue.getAllIdNameTuples(schemaItemName: selectedItem.value.schemaItemName!)
                vc?.delegate = self
                self.show(vc!, sender: self)
                break
            case WpTypes.date:
                let vc = UIStoryboard.EditDateVC()
                vc?.schemaItem = selectedItem.value
                vc?.delegate = self
                self.show(vc!, sender: self)
                break
            case WpTypes.duration:
                let vc = UIStoryboard.EditHoursVC()
                vc?.schemaItem = selectedItem.value
                vc?.delegate = self
                self.show(vc!, sender: self)
                break
            case WpTypes.complex:
                let vc = UIStoryboard.EditMultipleChoicesVC()
                
                switch selectedItem.value.schemaItemName! {
                case "type":
                    vc?.values = Type.getAllIdNameTuples(projectId, instanceId: instanceId)
                break
                case "priority":
                    vc?.values = Priority.getAllIdNameTuples(projectId, instanceId: instanceId)
                break
                case "version":
                    vc?.values = Version.getAllIdNameTuples(projectId, instanceId: instanceId)
                break
                case "status":
                    vc?.values = Status.getAllIdNameTuples(projectId, instanceId: instanceId, alloweForNew: true)
                break
                case "assignee":
                    vc?.values = Assignee.getAllAvailableAssigneesIdNameTuples(projectId, instanceId: instanceId)
                break
                case "responsible":
                    vc?.values = Assignee.getAllAvailableResponsiblesdNameTuples(projectId, instanceId: instanceId)
                break
                default:
                    vc?.values = [(id: Int, name: String, href: String)]()
                break
                }
                vc?.schemaItem = selectedItem.value
                vc?.delegate = self
                self.show(vc!, sender: self)
                break
            default:
                break
            }
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
        var value: WorkPackageFormSchema
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
                self.workpackageFormSchemaItems = WorkPackageFormSchema.mr_findAll() as? [WorkPackageFormSchema]
                self.defineSections()
                self.tableView.reloadData()
                LoadingUIView.hide()
            }
        })
    }
    
    func updateForm() {
        self.workpackageFormSchemaItems = WorkPackageFormSchema.mr_findAll() as? [WorkPackageFormSchema]
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
    
    func dateEditFinished() {
        updateForm()
    }
    
    func hoursEditFinished() {
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
    
    private func getSectionItems(items: [WorkPackageFormSchema]) -> [SectionItem] {
        var results = [SectionItem]()
        for item in items {
            let name = getName(str: item.name, required: item.required)
            let secItem = SectionItem(name: name, value: item)
            results.append(secItem)
        }
        return results
    }
}


