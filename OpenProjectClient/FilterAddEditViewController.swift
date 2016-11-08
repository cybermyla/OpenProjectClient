//
//  FilterAddEditViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol FilterAddEditViewControllerDelegate {
    func filterEditFinished()
}

class FilterAddEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    private var priorities: [Priority] = []
    private var types: [Type] = []
    private var statuses: [Status] = []
    
    private let defaults = UserDefaults.standard
    private var instanceId:String = ""
    private var projectId: NSNumber = -1
    
    private var sections: [Section] = []
    
    var delegate: FilterAddEditViewControllerDelegate?
    var editedFilter: WPFilter? = nil
    internal var edit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        //multiple items selection
        self.tableView.allowsMultipleSelection = true
        edit = editedFilter != nil ? true : false
        self.title = edit ? "Edit Filter" : "Create Filter"

        setupGraphics()
        
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        WPFilter.deselectAllFilters(projectId, instanceId: instanceId)
        addEditWPFilter()
        delegate?.filterEditFinished()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate?.filterEditFinished()
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func addEditWPFilter() {
        var filter: WPFilter?
        if edit {
            let editedF = editedFilter!
            let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@ AND name == %@", argumentArray: [editedF.instanceId!, editedF.projectId, editedF.name!])
            filter = WPFilter.mr_findFirst(with: predicate) as WPFilter
        } else {
            filter = WPFilter.mr_createEntity()
        }
        
        if !edit {
            filter?.projectId = Int32(projectId)
            filter?.instanceId = instanceId
            filter?.selected = true
        }
        
        var typeIds: [Int32] = []
        var typeNames: [String] = []
        let typeRows = sections[0].items

        for row in typeRows {
            if row.checked {
                typeNames.append(row.name)
                typeIds.append(row.id)
            }
        }
        filter?.types = typeIds as NSObject?
        filter?.typeNames = typeNames as NSObject?
        
        var statusIds: [Int32] = []
        var statusNames: [String] = []
        let statusRows = sections[1].items
        for row in statusRows {
            if row.checked {
                statusNames.append(row.name)
                statusIds.append(row.id)
            }
        }
        filter?.statuses = statusIds as NSObject?
        filter?.statusNames = statusNames as NSObject?
        
        var priorityIds: [Int32] = []
        var priorityNames: [String] = []
        let priorityRows = sections[2].items
        for row in priorityRows {
            if row.checked {
                priorityNames.append(row.name)
                priorityIds.append(row.id)
            }
        }
        filter?.priorities = priorityIds as NSObject?
        filter?.priorityNames = priorityNames as NSObject?
        
        filter?.name = "[\(typeNames.joined(separator: ";"))],[\(statusNames.joined(separator: ";"))],[\(priorityNames.joined(separator: ";"))]"
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func getData() {
        instanceId = defaults.value(forKey: "InstanceId") as! String!
        projectId = defaults.value(forKey: "ProjectId") as! NSNumber!
        priorities = Priority.getAllPriorities(projectId, instanceId: instanceId)
        types = Type.getAllTypes(projectId, instanceId: instanceId)
        statuses = Status.getAllStatuses(projectId, instanceId: instanceId)
        
        var typeFilterItems: [FilterItem] = []
        
        var editedFilterTypes: [Int] = []
        if edit {
            editedFilterTypes = editedFilter?.types as! [Int]
        }
        for item in types {
            let checked = editedFilterTypes.contains(Int(item.id))
            typeFilterItems.append(FilterItem(name: item.name!, id: item.id, checked: checked))
        }
        sections.append(Section(heading: "Types", items: typeFilterItems))
        
        
        var statusFilterItems: [FilterItem] = []
        var editedFilterStatuses: [Int] = []
        if edit {
            editedFilterStatuses = editedFilter?.statuses as! [Int]
        }
        for item in statuses {
            let checked = editedFilterStatuses.contains(Int(item.id))
            statusFilterItems.append(FilterItem(name: item.name!, id: item.id, checked: checked))
        }
        sections.append(Section(heading: "Statuses", items: statusFilterItems))
        
        var priorityFilterItems: [FilterItem] = []
        var editedFilterPriorities: [Int] = []
        if edit {
            editedFilterPriorities = editedFilter?.priorities as! [Int]
        }
        for item in priorities {
            let checked = editedFilterPriorities.contains(Int(item.id!))
            priorityFilterItems.append(FilterItem(name: item.name!, id: item.id as! Int32, checked: checked))
        }
        sections.append(Section(heading: "Priorities", items: priorityFilterItems))
    }
    
    func setupGraphics() {
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        saveButton.backgroundColor = Colors.darkAzureOP.getUIColor()
        saveButton.tintColor = UIColor.white
        
        cancelButton.backgroundColor = Colors.lightAzureOP.getUIColor()
        cancelButton.tintColor = UIColor.white
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterAddEditTableViewCell") as! FilterAddEditTableViewCell!
        cell?.selectionStyle = .none
        let item = sections[indexPath.section].items[indexPath.row]
        cell?.textLabel?.text = item.name
        if item.checked {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath[0]].items[indexPath[1]].checked = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        sections[indexPath[0]].items[indexPath[1]].checked = false
    }
    
    
    private struct Section {
        var heading: String
        var items: [FilterItem]
        
        init(heading: String, items: [FilterItem]) {
            self.heading = heading
            self.items = items
        }
    }
    
    private struct FilterItem {
        var name: String
        var id: Int32
        var checked: Bool
        
    }

}
