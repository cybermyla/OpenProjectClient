//
//  NewWorkPackageViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol NewWorkPackageVCDelegate {
    func workpackageCreationUpdateFinished(workPackageId: Int32)
}

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
    
    var delegate: NewWorkPackageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getAvailableAssignees()
        // Do any additional setup after loading the view.
        if let _ = workpackage {
            getEditForm()
            self.navigationItem.title = "Edit Work Package"
            nextButton.titleLabel?.text = "UPDATE"
        } else {
            getNewForm()
            self.navigationItem.title = "New Work Package"
            nextButton.titleLabel?.text = "CREATE"
        }
        
        
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
        let section3 = Section(heading: "People", items: getSectionItems(items: sectItems3))
        if section3.items.count > 0 {
            sections.append(section3)
        }
        
        let sectItems4 = WorkPackageFormSchema.getItemsBySection(section: 3)
        let section4 = Section(heading: "Estimates & Time", items: getSectionItems(items: sectItems4))
        if section4.items.count > 0 {
            sections.append(section4)
        }
        
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
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        validateFormAndCreateNewWorkpackage()
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
            case WpTypes.duration, WpTypes.integer:
                let vc = UIStoryboard.EditHoursVC()
                vc?.schemaItem = selectedItem.value
                switch selectedItem.value.schemaItemName! {
                case "percentageDone":
                    vc?.intValues = [Int](0...100)
                    vc?.unit = "%"
                    break
                case "remainingTime", "estimatedTime":
                    vc?.intValues = [Int](0...500)
                    vc?.unit = "h"
                    break
                default:
                    vc?.intValues = [Int](0...500)
                    vc?.unit = ""
                    break
                }
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
                self.showRequestErrorAlert(error: issue)
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
                self.showRequestErrorAlert(error: issue)
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
                self.showRequestErrorAlert(error: issue)
                LoadingUIView.hide()
            } else {
                self.workpackageFormSchemaItems = WorkPackageFormSchema.mr_findAll() as? [WorkPackageFormSchema]
                self.defineSections()
                self.tableView.reloadData()
                LoadingUIView.hide()
            }
        })
    }
    
    func getEditForm() {
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getWorkpackagesUpdateFormsPayload(wpId: workpackage!.id,onCompletion: {(responseObject:Bool, error:NSError?) in
            if let issue = error {
                print(issue.description)
                self.showRequestErrorAlert(error: issue)
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
 /*
    func dateToString(date: NSDate) -> String {
        return "Some date"
    }
 */   
    
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
    
    private func showAlert(title: String, str: String) {
        let alert = UIAlertController(title: title, message: str, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func validateFormAndCreateNewWorkpackage() {
        let payload = WorkPackageFormSchema.getPayload()
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.verifyWorkpackageFormPayload(wpId: workpackage?.id, payload: payload, onCompletion: {(responseObject:JSON, error:NSError?) in
            if let issue = error {
                print("FATAL - Payload verification request failed\n\(issue)")
                self.showRequestErrorAlert(error: issue)
                LoadingUIView.hide()
            } else {
                print("Payload verification response received")
                print(responseObject)
                LoadingUIView.hide()

                if let errors = ResponseValidationError.getFormErrors(json: responseObject) {
                    LoadingUIView.hide()
                    print("Form is not valid")
                    self.showResponseErrorAlert(errors: errors)
                } else {
                    print("Form is valid")
                    //create new workpackage
                    let finalPayload = WorkPackageFormSchema.getValidatedPayload(json: responseObject)
                    print(finalPayload)
                    
                    OpenProjectAPI.sharedInstance.createOrUpdateWorkpackage(wpId: self.workpackage?.id, payload: finalPayload, onCompletion: {(submitionResponseObject:JSON, error:NSError?) in
                        if let issue = error {
                            print("New Workpackage request failed")
                            print(issue.description)
                            self.showRequestErrorAlert(error: issue)
                            LoadingUIView.hide()
                        } else {
                            LoadingUIView.hide()
                            print(submitionResponseObject)
                            if let errors = ResponseValidationError.getRequestErrors(json: submitionResponseObject) {
                                LoadingUIView.hide()
                                print("New Workpackage has not been created")
                                self.showResponseErrorAlert(errors: errors)
                            } else {
                                print(submitionResponseObject)
                                let id = self.parseUpdatedWorkPackage(json: submitionResponseObject)
                                self.delegate?.workpackageCreationUpdateFinished(workPackageId: id)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        })
    }
    
    private func parseUpdatedWorkPackage(json: JSON) -> Int32 {
        return WorkPackage.buildWorkPackage(projectId: projectId, instanceId: instanceId, item: json, saveToContext: true)
    }
    
    private func showResponseErrorAlert(errors: [ResponseValidationError]) {
        let alertController = ErrorAlerts.getAlertController(errors: errors, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showRequestErrorAlert(error: Error) {
        let alertController = ErrorAlerts.getAlertController(error: error, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
}


